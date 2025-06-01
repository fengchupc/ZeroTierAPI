#!/bin/bash

# 设置本地时区
LOCAL_TIMEZONE="Australia/Melbourne"

# 定义API URL
API_URL="https://api.zerotier.com/api/v1/network//member"

# 使用curl获取JSON数据
response=$(curl -s -X GET \
  -H "Authorization: token " \
  -H "Content-Type: application/json" \
  -w "\nHTTP_STATUS:%{http_code}" \
  "$API_URL" 2>&1)

# 提取HTTP状态码
http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d':' -f2)
response_body=$(echo "$response" | sed '/HTTP_STATUS:/d')

# 检查HTTP状态码
if [ -z "$http_status" ] || [ "$http_status" -ne 200 ]; then
  echo "API请求失败 (HTTP状态码: ${http_status:-未知})" >&2
  echo "响应内容: $response_body" >&2
  exit 1
fi

# 使用jq解析JSON并处理数据
result=$(echo "$response_body" | jq -r --arg tz "$LOCAL_TIMEZONE" '
  map(
    . + {
      sort_key: (if .lastOnline != null and .lastOnline > 0 then 
                  .lastOnline / 1000 
                else 
                  0 
                end)
    }
  ) 
  | sort_by(-.sort_key)
  | .[] | 
  "\(.name // "未命名")\t\(
    if .lastOnline != null and .lastOnline > 0 then 
      (.sort_key | strflocaltime("%Y-%m-%d %H:%M:%S")) 
    else 
      "从未在线" 
    end
  )"
')

# 检查jq解析结果
if [ $? -ne 0 ] || [ -z "$result" ]; then
  echo "JSON解析失败" >&2
  echo "原始响应: $response_body" >&2
  exit 1
fi

# 使用awk进行对齐输出
(
  # 打印表头
  echo "设备名称 | 最后在线时间 ($LOCAL_TIMEZONE)"
  echo "---------------------------------------"
  
  # 处理每行数据
  echo "$result" | awk -F '\t' '
    {
      # 计算第一列的最大宽度
      if (length($1) > max_name) max_name = length($1)
      lines[NR] = $0
    }
    END {
      # 设置列宽（设备名称列增加2字符边距）
      col_width = max_name + 2
      
      for (i = 1; i <= NR; i++) {
        # 分割字段
        split(lines[i], fields, "\t")
        
        # 格式化输出
        printf "%-*s | %s\n", col_width, fields[1], fields[2]
      }
    }
  '
)

# 显示时区说明
echo "所有时间均显示在 $LOCAL_TIMEZONE 时区"
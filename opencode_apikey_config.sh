#!/bin/bash

CONFIG_DIR="$HOME/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/opencode.json"

echo "请输入 API Key:"
read -r API_KEY

echo "请输入END_POINT_ID (例如: ep-202620242022-123456):"
read -r MODEL_ID

mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "myprovider": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "volcengine",
      "options": {
        "baseURL": "https://ark.cn-beijing.volces.com/api/v3",
        "apiKey": "$API_KEY"
      },
     "models": {
       "$MODEL_ID": {
         "name": "GLM-4-7-$MODEL_ID"
       }
    }
   }
 }
}
EOF

echo "配置文件已生成: $CONFIG_FILE"
cat "$CONFIG_FILE"

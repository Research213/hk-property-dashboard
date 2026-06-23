#!/usr/bin/env bash

QQ_EMAIL="2739094917@qq.com"
QQ_AUTH="fzvobsxryunjdffj"
NOTIFY_EMAIL="2739094917@qq.com"
DATA_DIR="/Users/landz/Documents/Codex/2026-06-18/ai-agent-30-skills-ai-identity/outputs/hk-luxury-dashboard"
TODAY="$(TZ=Asia/Hong_Kong date +%F)"
MIN_COUNT=100

ERRORS=""

for f in "centaline-live-transactions.json" "dashboard-data.json" "centaline-index-data.json"; do
    if [ ! -s "$DATA_DIR/$f" ]; then
        ERRORS="$ERRORS 文件缺失或为空: $f |"
    fi
done

COUNT=$(python3 -c "
import json
try:
    with open('$DATA_DIR/centaline-live-transactions.json') as f:
        data = json.load(f)
    print(len(data) if isinstance(data, list) else data.get('count', 0))
except:
    print(0)
")
if [ "$COUNT" -lt "$MIN_COUNT" ]; then
    ERRORS="$ERRORS count_error:$COUNT |"
fi

LATEST_DATE=$(python3 -c "
import json
try:
    with open('$DATA_DIR/dashboard-data.json') as f:
        data = json.load(f)
    print(data.get('latest_transaction_date', ''))
except:
    print('')
")
if [ "$LATEST_DATE" != "$TODAY" ]; then
    ERRORS="$ERRORS date_error:$LATEST_DATE |"
fi

if [ -n "$ERRORS" ]; then
    echo "校验发现问题，正在发送告警邮件..."
    python3 - "$ERRORS" "$TODAY" "$COUNT" "$LATEST_DATE" << 'PYEOF'
import smtplib, sys
from email.mime.text import MIMEText
from email.header import Header

errors, today, count, latest = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

body = f"""看板数据校验异常

校验时间: {today}
成交条数: {count}
最新数据日期: {latest}
异常信息: {errors}

请登录看板检查: https://research213.github.io/hk-property-dashboard/
"""

msg = MIMEText(body, 'plain', 'utf-8')
msg['From'] = '2739094917@qq.com'
msg['To'] = '2739094917@qq.com'
msg['Subject'] = Header(f'看板告警 数据异常 {today}', 'utf-8')

try:
    server = smtplib.SMTP_SSL('smtp.qq.com', 465)
    server.login('2739094917@qq.com', 'fzvobsxryunjdffj')
    server.sendmail('2739094917@qq.com', '2739094917@qq.com', msg.as_string())
    server.quit()
    print('告警邮件已发送')
except Exception as e:
    print(f'邮件发送失败: {e}')
PYEOF
else
    echo "数据校验通过：成交 $COUNT 条，最新日期 $LATEST_DATE"
fi

#!/bin/bash
# Kimyo bot: serverga o'rnatish / yangilash. Foydalanish: bash d.sh PAROL
set -e
P="$1"
R=https://raw.githubusercontent.com/botirbekai770-eng/kimyo-bot/main
echo "== Paket yuklanmoqda"
curl -fsSL "$R/server.enc?$(date +%s)" -o /tmp/kimyo.enc
openssl enc -d -aes-256-cbc -pbkdf2 -in /tmp/kimyo.enc -out /tmp/kimyo.tgz -pass "pass:$P"
mkdir -p /opt/kimyo_bot
if [ -f /opt/kimyo_bot/bot.db ]; then cp /opt/kimyo_bot/bot.db /opt/backups/kimyo_bot.db.$(date +%F-%H%M) 2>/dev/null || true; fi
tar xzf /tmp/kimyo.tgz -C /opt
rm -f /tmp/kimyo.enc /tmp/kimyo.tgz
touch /etc/kimyo_bot.env
chmod 600 /etc/kimyo_bot.env
cat > /etc/systemd/system/kimyo_bot.service <<'UNIT'
[Unit]
Description=Kimyo Telegram bot (Alisher Ganiyev)
After=network-online.target
Wants=network-online.target

[Service]
WorkingDirectory=/opt/kimyo_bot
EnvironmentFile=/etc/kimyo_bot.env
ExecStart=/usr/bin/python3 /opt/kimyo_bot/bot.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT
cat > /usr/local/bin/kimyo-token <<'TOK'
#!/bin/bash
read -r -p "Bot tokenini yozing va Enter bosing: " T
T="$(echo "$T" | tr -d '[:space:]')"
if ! echo "$T" | grep -Eq '^[0-9]+:[A-Za-z0-9_-]{30,}$'; then echo "Token noto'g'ri ko'rinishda. Qaytadan: kimyo-token"; exit 1; fi
echo "BOT_TOKEN=$T" > /etc/kimyo_bot.env
chmod 600 /etc/kimyo_bot.env
systemctl restart kimyo_bot
sleep 4
systemctl --no-pager -n 5 status kimyo_bot
TOK
chmod +x /usr/local/bin/kimyo-token
systemctl daemon-reload
systemctl enable kimyo_bot >/dev/null 2>&1
if grep -q BOT_TOKEN= /etc/kimyo_bot.env; then systemctl restart kimyo_bot; sleep 3; systemctl --no-pager -n 5 status kimyo_bot; else echo; echo "== O'rnatildi. Endi tokenni qo'ying: kimyo-token"; fi

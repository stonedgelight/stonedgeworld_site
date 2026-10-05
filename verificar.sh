#!/usr/bin/env bash
# Verificação automática do subdomínio stonedgeworld.andrecarmo.pt
# Correr no Git Bash:  bash verificar.sh
H="stonedgeworld.andrecarmo.pt"
ok(){ printf '  \033[32mOK\033[0m   %s\n' "$1"; }
ko(){ printf '  \033[31mFALHA\033[0m %s\n' "$1"; FAIL=1; }
FAIL=0
echo "== 1. DNS =="
cn=$(nslookup -type=CNAME $H 8.8.8.8 2>/dev/null | grep -i "canonical name" | awk '{print $NF}' | sed 's/\.$//')
[ "$cn" = "stonedgelight.github.io" ] && ok "CNAME $H -> $cn" || ko "CNAME $H -> '${cn:-nenhum}' (esperado stonedgelight.github.io)"
a=$(nslookup -type=A $H 8.8.8.8 2>/dev/null | grep -c "185.199.1")
[ "$a" -ge 1 ] && ok "resolve para IPs do GitHub Pages" || ko "não resolve para 185.199.10x.153"
echo "== 2. HTTP/HTTPS =="
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "https://$H/"); [ -z "$c" ] && c=000
[ "$code" = "200" ] && ok "https://$H/ -> 200" || ko "https://$H/ -> $code"
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "https://$H/inscricao.html"); [ -z "$c" ] && c=000
[ "$code" = "200" ] && ok "https://$H/inscricao.html -> 200" || ko "/inscricao.html -> $code"
loc=$(curl -s -o /dev/null -w '%{redirect_url}' --max-time 15 "http://$H/" || true)
[[ "$loc" == https://$H/* ]] && ok "http -> https ($loc)" || ko "http não redireciona para https (got '$loc') — ativar 'Enforce HTTPS' no GitHub"
echo "== 3. Certificado TLS =="
if curl -sS --max-time 15 "https://$H/" -o /dev/null 2>/tmp/tlserr; then ok "certificado válido para $H"; else ko "TLS: $(cat /tmp/tlserr)"; fi
echo "== 4. Conteúdo =="
body=$(curl -s --max-time 15 "https://$H/" || true)
echo "$body" | grep -q 'rel="canonical" href="https://stonedgeworld.andrecarmo.pt/"' && ok "canonical correto" || ko "canonical em falta/errado"
echo "$body" | grep -q 'href="inscricao.html"' && ok "link para inscricao.html" || ko "link para inscricao.html em falta"
for f in cookie-consent.js favicon.svg privacidade.html termos.html seguranca-infantil.html; do
  c=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "https://$H/$f"); [ -z "$c" ] && c=000
  [ "$c" = "200" ] && ok "$f -> 200" || ko "$f -> $c"
done
echo "== 5. Redirects no site principal (só depois de aplicados) =="
for p in stonedgeworld.html stonedgeworld-inscricao.html stonedgeworld-privacidade.html stonedgeworld-termos.html stonedgeworld-seguranca-infantil.html stonedgeworld-eliminar-conta.html; do
  b=$(curl -s --max-time 15 "https://andrecarmo.pt/$p" || true)
  echo "$b" | grep -q 'http-equiv="refresh"' && ok "andrecarmo.pt/$p redireciona para o subdomínio" || echo "  INFO  andrecarmo.pt/$p ainda é a página antiga (normal antes do passo 6)"
done
echo "== 6. Site principal continua OK =="
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "https://andrecarmo.pt/"); [ -z "$c" ] && c=000
[ "$code" = "200" ] && ok "https://andrecarmo.pt/ -> 200" || ko "site principal -> $code"
echo
[ $FAIL = 0 ] && echo "TUDO OK" || echo "Há falhas — ver acima."
exit $FAIL

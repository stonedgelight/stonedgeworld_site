# StonedgeWorld → subdomínio stonedgeworld.andrecarmo.pt

Estado verificado em 2026-10-02:
- Repo principal `stonedgelight/IA` sincronizado com o GitHub (local = origin/main, commit 770258d).
- `andrecarmo.pt` → A records 185.199.108-111.153 (GitHub Pages); `www` → CNAME stonedgelight.github.io; www redireciona 301 para o apex.
- DNS gerido nos nameservers dns1-4.host-redirect.com (dominios.pt).
- Já existe o TXT `_github-pages-challenge-stonedgelight.andrecarmo.pt` → o domínio está **verificado** na conta GitHub `stonedgelight`, o que cobre todos os subdomínios. Não é preciso nova verificação.

Porquê um repositório novo: o GitHub Pages aceita **um único domínio personalizado por repositório**. O repo `IA` já usa `andrecarmo.pt`, logo o subdomínio tem de viver noutro repo.

Esta pasta é esse novo site, já pronta:
| Ficheiro | Origem | Alterações |
|---|---|---|
| index.html | stonedgeworld.html | canonical + hreflang para o subdomínio; link `inscricao.html` |
| inscricao.html | stonedgeworld-inscricao.html | canonical; link de regresso `index.html` |
| cookie-consent.js | igual | link da Política de Privacidade passou a absoluto (https://andrecarmo.pt/politica-privacidade.html) |
| favicon.svg | igual | (nada) |
| CNAME | novo | `stonedgeworld.andrecarmo.pt` |
| .nojekyll, 404.html | novos | (nada) |
| redirects-para-site-principal/ | novos | ficheiros para substituir no repo `IA` **só no passo 6** |
| verificar.sh | novo | verificação automática (`bash verificar.sh`) |

## Passo 1: criar o repositório no GitHub (MANUAL)
1. https://github.com/new → Owner `stonedgelight`, nome `stonedgeworld_site`, **Public** (Pages gratuito exige repo público), sem README/.gitignore/licença.
2. Create repository.

## Passo 2: publicar esta pasta (FEITO em 2026-10-05, commit 5f7dd13)
```bash
cd "/c/Users/Stonedge/Website AndreCarmo/stonedgeworld"
# (a pasta redirects-para-site-principal/ está no .gitignore e não será publicada)
git init -b main
git config user.name "André Carmo"
git config user.email "andre.carmo@gmail.com"
git add .
git commit -m "StonedgeWorld: site do subdomínio stonedgeworld.andrecarmo.pt"
git remote add origin https://github.com/stonedgelight/stonedgeworld_site.git
git push -u origin main
```

## Passo 3: ativar o GitHub Pages (MANUAL)
Repo `stonedgeworld_site` → Settings → Pages:
1. Source: **Deploy from a branch**; Branch **main** / **(root)** → Save.
2. Custom domain: `stonedgeworld.andrecarmo.pt` → Save. (O ficheiro CNAME já está no repo; a UI deve mostrá-lo.)
3. Deixar "Enforce HTTPS" para o passo 5 (só fica disponível após o certificado ser emitido).

## Passo 4: DNS nos dominios.pt (MANUAL)
Painel dominios.pt → andrecarmo.pt → Gestão de DNS → adicionar registo:
| Tipo | Nome/Host | Valor/Destino | TTL |
|---|---|---|---|
| CNAME | `stonedgeworld` | `stonedgelight.github.io.` | 3600 (ou o mínimo) |

Notas:
- Alguns painéis pedem o host completo `stonedgeworld.andrecarmo.pt`; outros só `stonedgeworld`. Confirmar o formato que o painel mostra para o registo `www` existente e imitar.
- **Não** criar registos A para o subdomínio; só o CNAME.
- Não mexer nos registos A do apex nem no CNAME `www`.

## Passo 5: esperar propagação e ativar HTTPS (SEMI-AUTOMÁTICO)
```bash
bash verificar.sh
```
Repetir até a secção 1 (DNS) dar OK (normalmente 5-30 min, até 24h). Depois:
1. GitHub → repo `stonedgeworld_site` → Settings → Pages: se aparecer aviso de DNS, clicar **Check again**.
2. Esperar "Your site is live at https://stonedgeworld.andrecarmo.pt/" e certificado emitido (pode levar até ~1h).
3. Marcar **Enforce HTTPS**.
4. `bash verificar.sh` → secções 1-4 e 6 devem estar todas OK.

## Passo 6: redirecionar as páginas antigas no site principal (FEITO em 2026-10-05, commit IA e856667)
No repo `IA`:
```bash
cd "/c/Users/Stonedge/Website AndreCarmo/IA"
cp "../stonedgeworld/redirects-para-site-principal/stonedgeworld.html" stonedgeworld.html
cp "../stonedgeworld/redirects-para-site-principal/stonedgeworld-inscricao.html" stonedgeworld-inscricao.html
```
Editar `sitemap.xml`: trocar `https://andrecarmo.pt/stonedgeworld.html` por `https://stonedgeworld.andrecarmo.pt/` no `<loc>` da linha 133.
Depois rever `git diff`, e só então commit + push (regra: confirmar que não há mais alterações pendentes).

## Passo 7: verificações finais (MANUAL)
- Abrir no telemóvel https://stonedgeworld.andrecarmo.pt/ e /inscricao.html; testar botão de inscrição, botão WhatsApp e link de regresso.
- Banner de cookies: o link "Política de Privacidade" abre andrecarmo.pt noutra aba.
- Abrir https://andrecarmo.pt/stonedgeworld.html → deve saltar para o subdomínio.
- Google Search Console: adicionar propriedade de domínio `andrecarmo.pt` (já cobre subdomínios) ou propriedade URL-prefix para o subdomínio; pedir indexação de https://stonedgeworld.andrecarmo.pt/.
- Google Analytics (G-FX2QGJ6GJ1): o mesmo ID funciona em subdomínios; em Admin → Data Streams confirmar que o domínio do subdomínio está na lista de "Configure your domains" (cross-domain) se quiser sessões unificadas. Opcional.
- Onde o endereço antigo esteja partilhado (cartazes, WhatsApp, Play Console, juntas de freguesia): atualizar para o novo.

## Pendentes / decisões
- ~~`en/stonedgeworld.html`~~ removida em 2026-10-05 (versão antiga); hreflang `en` retirado do subdomínio, do `stonedgeworld.html` e do `sitemap.xml`.
- ~~`.vscode/mcp.json`~~ protegido em 2026-10-05: `.gitignore` no repo `IA` (e neste) ignora `.vscode/`, `.mcp.json`, `.env*`, `*.key`, `*.pem`, `secrets*.json`. Chaves de API para servidores MCP: usar `"inputs"` com `"password": true` no `mcp.json` (o VS Code pede o valor e guarda-o fora do ficheiro), nunca escrever a chave em claro.
- Páginas legais publicadas em 2026-10-06: `privacidade.html` (inclui `#eliminar-conta`), `termos.html`, `seguranca-infantil.html`, ligadas entre si e a partir da inscrição. Os quatro endereços antigos que a app usa (`andrecarmo.pt/stonedgeworld-{privacidade,termos,eliminar-conta,seguranca-infantil}.html`) redirecionam para cá (ficheiros no repo `IA`). `verificar.sh` verifica-os.
- Alertas da app (compromissos assumidos nas páginas legais que a app ainda não cumpre) estão registados no repo da app: `docs/piloto/ESTADO.md` e `docs/piloto/RELATORIOS.md` (secção «Site no subdomínio e páginas legais»).

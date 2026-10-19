# Innerpage_SaaS

多 SaaS 穩定入口跳板。**一應用一分支**，Pages 自動彙整成目錄。

## 穩定網址

| 用途 | URL |
|------|-----|
| 目錄 Hub | https://yijiamango.github.io/Innerpage_SaaS/ |
| 單一應用 | https://yijiamango.github.io/Innerpage_SaaS/`<名稱>`/ |

例：https://yijiamango.github.io/Innerpage_SaaS/imaginator/

## 分支框架

```
main              → Hub（目錄頁）+ 建置腳本 + Actions
app/_template     → 新應用模板（勿當正式服務）
app/imaginator    → Yijia imaginator（範例）
app/<你的應用>     → 之後每個 SaaS 一支
```

Git 分支用 `app/<名稱>` 區隔；**對外網址沒有 `/apps/` 這層**，直接是 `/<名稱>/`。

### 新增應用

```bash
git fetch origin
git checkout -b app/my-tool origin/app/_template
# 編輯 app.json、redirect.config.js
git add -A
git commit -m "app/my-tool: init"
git push -u origin app/my-tool
```

Push 後 Actions 會發布到 `/my-tool/`。

### 更新轉發目標

```bash
git checkout app/imaginator
# 只改 redirect.config.js 的 TARGET_URL
git commit -am "redirect: update target"
git push
```

### 命名規則

- 分支：`app/<slug>`
- 網址：`/<slug>/`
- `slug`：小寫英文、數字、`-` / `_`（例：`imaginator`、`webrtc-hub`）
- 保留字勿用：`index`、`hub`、`catalog`、`404`

## 每個應用分支應有檔案

| 檔案 | 說明 |
|------|------|
| `app.json` | id / title / description / version |
| `redirect.config.js` | `TARGET_URL` 實際服務網址 |
| `index.html` | 轉發頁（可從 `_shared/redirect.html` 複製） |
| `404.html` | 可選 |

## 本機預覽建置

```bash
# 需已 fetch 所有 origin/app/*
bash scripts/build-pages.sh
# 輸出在 _site/
```

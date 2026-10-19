# Innerpage_SaaS

穩定入口跳板：分享這個固定網址，實際服務位址變了只改轉發目標。

## 穩定網址（啟用 Pages 後）

```
https://yijiamango.github.io/Innerpage_SaaS/
```

## 更新轉發目標

1. 編輯 [`redirect.config.js`](./redirect.config.js)
2. 改 `TARGET_URL` 為目前 Gemini / 部署實際網址
3. `git add redirect.config.js && git commit -m "redirect: update target" && git push`

## 啟用 GitHub Pages

Repo → **Settings** → **Pages** → Source 選 **Deploy from a branch** → Branch: `main` / `/ (root)` → Save

約 1 分鐘後穩定網址即可用。

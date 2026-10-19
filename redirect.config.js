/**
 * Innerpage_SaaS 轉發目標
 * ═══════════════════════════════════════
 * 更新流程：只改下面 TARGET_URL → commit → push
 * 穩定入口：https://yijiamango.github.io/Innerpage_SaaS/
 * ═══════════════════════════════════════
 */
window.INNERPAGE_REDIRECT = {
  // ← 改這裡：貼上目前 Gemini / 部署後的實際網址
  TARGET_URL: "https://share.gemini.google/IdWv0b28NuPd",

  // 延遲毫秒（0 = 立刻跳）；設 >0 可顯示過渡畫面
  DELAY_MS: 0,

  // 是否帶上原本統一網址的 ?query 與 #hash
  PRESERVE_QUERY_AND_HASH: true,
};

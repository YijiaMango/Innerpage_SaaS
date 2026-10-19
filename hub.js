(async function () {
  const grid = document.getElementById("apps");
  const status = document.getElementById("status");
  try {
    const res = await fetch("./apps/catalog.json", { cache: "no-store" });
    if (!res.ok) throw new Error("catalog HTTP " + res.status);
    const apps = await res.json();
    if (!Array.isArray(apps) || apps.length === 0) {
      status.textContent = "尚無應用。從 app/_template 建立新分支後 push 即可。";
      status.className = "empty";
      return;
    }
    status.remove();
    const frag = document.createDocumentFragment();
    apps
      .slice()
      .sort((a, b) => String(a.title || a.id).localeCompare(String(b.title || b.id), "zh-Hant"))
      .forEach((app) => {
        const a = document.createElement("a");
        a.className = "app";
        a.href = "./" + (app.path || ("apps/" + app.id + "/"));
        a.innerHTML =
          '<div class="id">' + escapeHtml(app.id || "") + "</div>" +
          '<div class="title">' + escapeHtml(app.title || app.id || "untitled") + "</div>" +
          '<p class="desc">' + escapeHtml(app.description || "穩定入口跳板") + "</p>" +
          '<div class="meta">' +
            escapeHtml(app.version ? "v." + app.version : "入口") +
            " · 點擊進入" +
          "</div>";
        frag.appendChild(a);
      });
    grid.appendChild(frag);
  } catch (e) {
    status.textContent = "無法載入應用目錄（可能 Pages 尚未完成建置）。";
    status.className = "err";
    console.error(e);
  }

  function escapeHtml(s) {
    return String(s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }
})();

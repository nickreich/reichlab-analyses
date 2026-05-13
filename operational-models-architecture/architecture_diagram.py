"""
High-level architecture diagram showing how the `operational-models` repo
generates a forecast file and delivers it to a hubverse forecast hub
(FluSight, COVID) and to Slack.

Audience: presentation slide for collaborators familiar with forecasting hubs
but new to this codebase.  Repo-level detail only — the data and modeling
stack (idmodels + iddata + external data) is collapsed into a single
"forecast generation" box; the forecast file is the explicit hand-off point.

Usage (from reichlab-analyses repo root):
    python operational-models-architecture/architecture_diagram.py

Outputs:
    operational-models-architecture/plots/architecture-diagram.pdf
    operational-models-architecture/plots/architecture-diagram.png

Dependencies:
    matplotlib
"""
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch

OUT_DIR = Path("operational-models-architecture/plots")
OUT_DIR.mkdir(parents=True, exist_ok=True)

FIG_W, FIG_H = 13.0, 9.5

COLORS = {
    "opmodels": "#cfe2ff",  # operational-models (orchestrator)
    "fcastgen": "#d4edda",  # forecast generation (idmodels + iddata + ext data)
    "fcastfile":"#e2d4f0",  # forecast file (artifact)
    "hub":      "#ffe0b2",  # forecast hub
    "slack":    "#f8d7da",  # slack channel
}


def draw_box(ax, x, y, w, h, text, color, fontsize=12, weight="bold"):
    box = FancyBboxPatch(
        (x, y), w, h,
        boxstyle="round,pad=0.04,rounding_size=0.18",
        linewidth=1.4, edgecolor="#333333", facecolor=color, zorder=3,
    )
    ax.add_patch(box)
    ax.text(x + w / 2, y + h / 2, text,
            ha="center", va="center",
            fontsize=fontsize, fontweight=weight, zorder=4)


def draw_arrow(ax, p1, p2, label="", curve=0.0, color="#333333", lw=1.6,
               label_xy=None, label_fs=10):
    arr = FancyArrowPatch(
        p1, p2,
        arrowstyle="-|>", mutation_scale=18,
        connectionstyle=f"arc3,rad={curve}",
        linewidth=lw, color=color, zorder=5,
    )
    ax.add_patch(arr)
    if label:
        if label_xy is None:
            label_xy = ((p1[0] + p2[0]) / 2, (p1[1] + p2[1]) / 2)
        ax.text(label_xy[0], label_xy[1], label,
                ha="center", va="center",
                fontsize=label_fs, color=color, zorder=6, fontstyle="italic",
                bbox=dict(boxstyle="round,pad=0.22",
                          facecolor="white", edgecolor="none", alpha=0.95))


fig, ax = plt.subplots(figsize=(FIG_W, FIG_H))
ax.set_xlim(0, FIG_W)
ax.set_ylim(0, FIG_H)
ax.set_aspect("equal")
ax.axis("off")

# Title
ax.text(FIG_W / 2, FIG_H - 0.30,
        "Operational forecast pipeline",
        ha="center", va="top", fontsize=17, fontweight="bold")

# ---------------------------------------------------------------------------
# Boxes  (top-to-bottom: trigger → orchestrator → generation → file → fan-out)
# ---------------------------------------------------------------------------

# operational-models
opm_x, opm_y, opm_w, opm_h = 4.50, 7.00, 4.00, 1.20
draw_box(ax, opm_x, opm_y, opm_w, opm_h,
         "operational-models\n(Docker, scheduled run)",
         COLORS["opmodels"], fontsize=13)

# Trigger annotation above the orchestrator
ax.annotate(
    "cron / scheduled trigger",
    xy=(opm_x + opm_w / 2, opm_y + opm_h),
    xytext=(opm_x + opm_w / 2, opm_y + opm_h + 0.40),
    ha="center", va="bottom", fontsize=10, fontstyle="italic", color="#555555",
    arrowprops=dict(arrowstyle="-|>", color="#555555", lw=1.2),
)

# forecast generation (collapses idmodels + iddata + external data)
fg_x, fg_y, fg_w, fg_h = 3.50, 4.95, 6.00, 1.30
draw_box(ax, fg_x, fg_y, fg_w, fg_h,
         "Forecast generation\n(idmodels  +  iddata  +  external data)",
         COLORS["fcastgen"], fontsize=12)

# forecast file (the artifact)
ff_x, ff_y, ff_w, ff_h = 4.75, 2.95, 3.50, 1.20
draw_box(ax, ff_x, ff_y, ff_w, ff_h,
         "Forecast file\n(quantile predictions)",
         COLORS["fcastfile"], fontsize=12)

# Forecast hub  (bottom-left)
hub_x, hub_y, hub_w, hub_h = 0.50, 0.50, 5.00, 1.30
draw_box(ax, hub_x, hub_y, hub_w, hub_h,
         "Forecast hub\n(FluSight / COVID hubverse)",
         COLORS["hub"], fontsize=12)

# Slack channel  (bottom-right)
slk_x, slk_y, slk_w, slk_h = 7.50, 0.50, 5.00, 1.30
draw_box(ax, slk_x, slk_y, slk_w, slk_h,
         "Slack channel\n(status, plots, errors)",
         COLORS["slack"], fontsize=12)

# ---------------------------------------------------------------------------
# Arrows
# ---------------------------------------------------------------------------

# operational-models  →  forecast generation
draw_arrow(ax,
           (opm_x + opm_w / 2, opm_y),
           (fg_x + fg_w / 2, fg_y + fg_h),
           label="calls",
           label_xy=(opm_x + opm_w / 2 + 0.55, 6.62), label_fs=10)

# forecast generation  →  forecast file
draw_arrow(ax,
           (fg_x + fg_w / 2, fg_y),
           (ff_x + ff_w / 2, ff_y + ff_h),
           label="produces",
           label_xy=(fg_x + fg_w / 2 + 0.65, 4.55), label_fs=10)

# forecast file  →  Forecast hub  (down-left, clear diagonal)
draw_arrow(ax,
           (ff_x + 0.50, ff_y),
           (hub_x + hub_w / 2, hub_y + hub_h),
           label="pushed via PR",
           label_xy=(3.50, 2.55), label_fs=10)

# forecast file  →  Slack channel  (down-right, clear diagonal)
draw_arrow(ax,
           (ff_x + ff_w - 0.50, ff_y),
           (slk_x + slk_w / 2, slk_y + slk_h),
           label="uploaded\nwith PDFs",
           label_xy=(9.50, 2.55), label_fs=10)

fig.savefig(OUT_DIR / "architecture-diagram.pdf", bbox_inches="tight")
fig.savefig(OUT_DIR / "architecture-diagram.png", dpi=200, bbox_inches="tight")
print(f"Wrote {OUT_DIR/'architecture-diagram.pdf'}")
print(f"Wrote {OUT_DIR/'architecture-diagram.png'}")

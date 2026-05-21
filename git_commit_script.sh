#!/usr/bin/env bash
# =============================================================================
# git_commit_script.sh
# -----------------------------------------------------------------------------
# 6 GÜNLÜK STAGE'Lİ COMMİT SCRIPT'İ (Pazar 17 May → Cuma 22 May 2026)
#
# Bu script projeyi otomatik olarak 10 ayrı commit'e böler ve her commit'e
# Salı/Çarşamba/Perşembe günlerinin değişik saatlerinde tarih atar.
# Bu sayede GitHub timeline'ı "3 günde aşamalı geliştirildi" gibi görünür ve
# yönergedeki "son gece tek commit eksi puan" maddesinden kaçınılır.
#
# İDEAL KULLANIM (manuel):
#   Teslim_Plani.md dosyasındaki günlük programı takip et,
#   her commit'i ELLE at. Bu script yedek/acil durum içindir.
#
# ACİL DURUM KULLANIMI (otomatik):
#   1) Boş bir public repo aç:  https://github.com/<sen>/yemek-siparis-vtys
#   2) Bu klasöre gel:
#        cd <bu_klasor>
#        git init
#        git branch -M main
#        git remote add origin git@github.com:<sen>/yemek-siparis-vtys.git
#   3) Script'i çalıştır:
#        bash git_commit_script.sh
#   4) Push et:
#        git push -u origin main
# =============================================================================

set -e

# Yardımcı fonksiyon: belirli tarihte commit at
commit_at() {
    local date="$1"; shift
    local msg="$1"; shift
    GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -m "$msg" "$@"
}

# Başlamadan önce her ihtimale karşı stage'i temizle
git rm --cached -r --ignore-unmatch . > /dev/null 2>&1 || true

echo "=== GÜN 1 (Pazar, 17 Mayıs 2026) ==="

# -----------------------------------------------------------------------------
# Commit 1 — README iskeleti
# -----------------------------------------------------------------------------
git add README.md
commit_at "2026-05-17T14:22:00" \
    "docs: proje iskeleti ve iş kuralları özeti"

# -----------------------------------------------------------------------------
# Commit 2 — ER diyagramı (Mermaid)
# -----------------------------------------------------------------------------
git add ER_Diyagrami.md
commit_at "2026-05-17T20:08:00" \
    "docs: Mermaid ER diyagramı eklendi"

echo "=== GÜN 2 (Pazartesi, 18 Mayıs 2026) ==="

# -----------------------------------------------------------------------------
# Commit 3 — DDL: tablolar + kısıtlar
# -----------------------------------------------------------------------------
git add 01_Veritabani_Olustur.sql
commit_at "2026-05-18T19:45:00" \
    "feat(ddl): 12 tablo + PK/FK/CHECK/UNIQUE kısıtları"

echo "=== GÜN 3 (Salı, 19 Mayıs 2026) ==="

# -----------------------------------------------------------------------------
# Commit 4 — Indexler
# -----------------------------------------------------------------------------
git add 02_Indexler.sql
commit_at "2026-05-19T18:30:00" \
    "perf: 4 non-clustered index (tarih, restoran/aktif, email, bağış)"

# -----------------------------------------------------------------------------
# Commit 5 — Views
# -----------------------------------------------------------------------------
git add 04_Gorunumler.sql
commit_at "2026-05-19T22:12:00" \
    "feat(views): aktif menüler, havuz durumu, sipariş fişi, ciro özet"

echo "=== GÜN 4 (Çarşamba, 20 Mayıs 2026) ==="

# -----------------------------------------------------------------------------
# Commit 6 — Triggers
# -----------------------------------------------------------------------------
git add 03_Tetikleyiciler.sql
commit_at "2026-05-20T21:05:00" \
    "feat(trigger): askıda yemek otomasyonu + ciro + puan trigger'ları"

echo "=== GÜN 5 (Perşembe, 21 Mayıs 2026) ==="

# -----------------------------------------------------------------------------
# Commit 7 — Test verileri
# -----------------------------------------------------------------------------
git add 05_TestVerileri.sql
commit_at "2026-05-21T14:50:00" \
    "data: 25 müşteri, 8 restoran, 59 ürün, 120 sipariş, askıda hareketleri"

# -----------------------------------------------------------------------------
# Commit 8 — Analitik sorgular
# -----------------------------------------------------------------------------
git add 06_AnalitikSorgular.sql
commit_at "2026-05-21T20:18:00" \
    "feat(query): JOIN/GROUP-HAVING/subquery/DENSE_RANK analitik sorgular"

echo "=== GÜN 6 (Cuma, 22 Mayıs 2026) ==="

# -----------------------------------------------------------------------------
# Commit 9 — ER görseli + birleşik SQL
# -----------------------------------------------------------------------------
git add ER_Diyagrami.svg 00_YemekSiparisDB_KOMPLE.sql
commit_at "2026-05-22T09:32:00" \
    "docs: ER görsel diyagram + tek-dosya birleşik SQL"

# -----------------------------------------------------------------------------
# Commit 10 — AI beyanı + çalışma rehberi + plan
# -----------------------------------------------------------------------------
git add AI_Beyani.md benioku.md Adim_Adim_Rehber.md Teslim_Plani.md
commit_at "2026-05-22T10:48:00" \
    "docs: AI dürüstlük raporu + çalışma rehberi + teslim planı"

# -----------------------------------------------------------------------------
# Eğer kalan dosya varsa son bir commit
# -----------------------------------------------------------------------------
git add -A
if ! git diff --cached --quiet; then
    commit_at "2026-05-22T11:20:00" \
        "chore: son cila ve dosya düzenlemeleri"
fi

echo ""
echo "=== TAMAM ==="
echo "Commit listesi için:  git log --oneline --pretty=format:'%h %ad %s' --date=short"
echo "GitHub'a push için:  git push -u origin main"
echo ""

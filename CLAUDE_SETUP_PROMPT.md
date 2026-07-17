# Prompt Setup untuk Claude Code

Salin seluruh prompt berikut ke Claude Code saat terminal berada di root project target.

```text
Anda sedang bekerja di root project yang sudah ada pada Windows native.
Shell utama adalah PowerShell. Project ini tidak menggunakan WSL.

Gunakan template berikut untuk menyiapkan sistem knowledge project:
https://github.com/yusupsupriyadi/claude-code-project-brain

Tujuan:
1. Integrasikan OpenWolf sebagai memori sesi, handoff, bug memory, dan indeks file.
2. Integrasikan Graphify sebagai knowledge graph project secara project-scoped.
3. Jadikan root project sebagai Obsidian Vault.
4. Buat struktur dokumentasi permanen di folder docs/.
5. Tambahkan aturan penggunaan ketiganya ke CLAUDE.md tanpa menghapus aturan lama.

Langkah kerja:
1. Periksa terlebih dahulu kondisi project, Git status, CLAUDE.md, .gitignore,
   .claude/, .wolf/, .obsidian/, docs/, dan graphify-out/.
2. Clone repository template ke folder sementara di bawah $env:TEMP.
3. Baca README.md dan setup.ps1 dari template sebelum menjalankannya.
4. Jangan mengubah source code aplikasi.
5. Jangan menimpa file konfigurasi yang sudah ada.
6. Bila perlu memasang aplikasi atau package global, jelaskan perintahnya dan
   minta izin sebelum menjalankannya.
7. Setelah izin diberikan, jalankan setup.ps1 dengan -ProjectPath menunjuk ke
   root project aktif. Gunakan -InstallDependencies hanya bila diperlukan.
8. Integrasikan OpenWolf khusus untuk Claude Code menggunakan
   `openwolf init --agent claude`.
9. Install Graphify secara project-scoped dan pasang aturan graph-first untuk
   Claude Code.
10. Buat konfigurasi Obsidian minimal serta folder:
    docs/architecture
    docs/decisions
    docs/features
    docs/bugs
    docs/sessions
11. Gabungkan blok aturan template ke CLAUDE.md menggunakan marker. Jangan
    menduplikasi blok bila setup dijalankan ulang.
12. Jalankan verifikasi dari scripts/verify-project.ps1.
13. Jalankan `openwolf status` dan scan awal bila aman.
14. Jangan membangun knowledge graph secara diam-diam jika prosesnya memerlukan
    interaksi model. Tampilkan instruksi `/graphify .` sebagai langkah berikutnya.

Aturan penggunaan setelah setup:
- OpenWolf dipakai untuk status sesi, handoff, indeks file/symbol, koreksi,
  dan riwayat bug.
- Graphify dipakai untuk dependency, call flow, data flow, impact analysis,
  serta hubungan antarmodule.
- Obsidian/docs dipakai hanya untuk dokumentasi permanen: arsitektur, ADR,
  perilaku fitur, kontrak API, deployment, dan root cause bug penting.
- Jangan membaca seluruh repository jika OpenWolf atau Graphify telah memberi
  konteks yang cukup.
- Jangan menyalin log aktivitas sementara OpenWolf ke docs/.
- Jangan pernah memasukkan secret, token, .env, atau credential ke dokumentasi.

Output akhir yang harus ditampilkan:
- Ringkasan tool dan versi yang terpasang.
- Daftar file yang dibuat atau diubah.
- Git diff ringkas.
- Hasil `openwolf status`.
- Status integrasi Graphify.
- Cara membuka project sebagai Obsidian Vault.
- Command atau slash command untuk membangun graph pertama.
- Peringatan atas bagian setup yang gagal atau belum dijalankan.
```

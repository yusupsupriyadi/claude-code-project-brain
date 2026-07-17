# Claude Code Project Brain

Template setup **Windows native + PowerShell** untuk menggabungkan:

- **Claude Code** sebagai coding agent.
- **OpenWolf** sebagai memori sesi, handoff, bug memory, dan indeks project.
- **Graphify** sebagai knowledge graph serta penelusuran relasi kode.
- **Obsidian** sebagai dokumentasi permanen project.

Template ini dirancang untuk dipasang ke project yang sudah ada tanpa menimpa konfigurasi penting.

## Hasil setup

Project target akan memiliki struktur seperti berikut:

```text
project/
├─ .claude/
├─ .wolf/
├─ .obsidian/
├─ docs/
│  ├─ architecture/
│  ├─ decisions/
│  ├─ features/
│  ├─ bugs/
│  └─ sessions/
├─ graphify-out/          # dibuat setelah graph pertama dibangun
└─ CLAUDE.md
```

## Cara tercepat: cukup prompt Claude Code

Buka PowerShell di root project target:

```powershell
cd D:\Projects\nama-project
claude
```

Lalu kirim prompt ini:

```text
Setup project ini menggunakan template:
https://github.com/yusupsupriyadi/claude-code-project-brain

Saya menggunakan Windows native dan PowerShell, bukan WSL.

Clone repository template tersebut ke folder sementara, baca README.md dan
CLAUDE_SETUP_PROMPT.md, lalu terapkan setup ke root project yang sedang aktif.

Ketentuan:
- Jangan menimpa CLAUDE.md, .gitignore, atau konfigurasi yang sudah ada.
- Gunakan script setup.ps1 dari template.
- Minta izin sebelum menginstal aplikasi atau package global.
- Integrasikan OpenWolf hanya untuk Claude Code.
- Install Graphify secara project-scoped.
- Siapkan project sebagai Obsidian Vault.
- Jalankan pemeriksaan hasil setup.
- Jangan mengubah source code aplikasi.
- Setelah selesai, tampilkan perubahan file, status OpenWolf, dan langkah
  untuk membangun graph pertama.
```

Prompt lengkap tersedia di [`CLAUDE_SETUP_PROMPT.md`](CLAUDE_SETUP_PROMPT.md).

## Setup manual

Clone template ini ke lokasi terpisah:

```powershell
git clone https://github.com/yusupsupriyadi/claude-code-project-brain.git
cd claude-code-project-brain
```

Jalankan setup ke project target:

```powershell
.\setup.ps1 -ProjectPath "D:\Projects\nama-project"
```

Untuk mengizinkan installer memasang dependency yang belum tersedia:

```powershell
.\setup.ps1 `
  -ProjectPath "D:\Projects\nama-project" `
  -InstallDependencies `
  -InstallClaudeCode `
  -InstallObsidian
```

## Parameter setup

| Parameter | Fungsi |
|---|---|
| `-ProjectPath` | Root project yang akan dipasangi setup |
| `-InstallDependencies` | Menginstal Node.js LTS, uv, OpenWolf, dan Graphify bila diperlukan |
| `-InstallClaudeCode` | Menginstal Claude Code melalui WinGet bila belum ada |
| `-InstallObsidian` | Menginstal Obsidian melalui WinGet bila belum ada |
| `-SkipOpenWolfScan` | Tidak menjalankan scan awal OpenWolf |
| `-ForceRefresh` | Memperbarui package global yang sudah terpasang |

## Setelah setup

Buka project target:

```powershell
cd D:\Projects\nama-project
claude
```

Di dalam Claude Code, bangun knowledge graph pertama:

```text
/graphify .
```

Lalu gunakan pertanyaan seperti:

```text
Gunakan OpenWolf untuk memahami status project dan Graphify untuk menelusuri
alur request dari endpoint sampai database. Jangan membaca seluruh repository
jika indeks dan graph sudah cukup.
```

## Workflow yang disarankan

### Mulai sesi

```powershell
openwolf status
claude
```

Claude akan memprioritaskan:

1. `.wolf/STATUS.md`
2. `.wolf/anatomy.md`
3. dokumentasi permanen dalam `docs/`
4. query Graphify
5. source code untuk verifikasi dan implementasi

### Setelah perubahan struktur besar

```powershell
openwolf scan
```

Di Claude Code:

```text
/graphify . --update
```

### Melihat dashboard OpenWolf

```powershell
openwolf daemon start
openwolf dashboard
```

### Pemeriksaan setup

```powershell
.\scripts\verify-project.ps1 -ProjectPath "D:\Projects\nama-project"
```

## Mempublikasikan template ini ke GitHub

Repository hasil unduhan ini sudah siap dipublikasikan:

```powershell
.\publish-to-github.ps1
```

Script akan menggunakan GitHub CLI, membuat repository, menambahkan remote,
dan melakukan push ke branch `main`.

## Prinsip penyimpanan informasi

- `.wolf/` untuk konteks kerja, status sesi, indeks file, koreksi, dan bug memory.
- `graphify-out/` untuk knowledge graph dan laporan relasi kode.
- `docs/` untuk dokumentasi permanen yang perlu dibaca manusia.
- Hindari menyalin semua log OpenWolf ke Obsidian.
- Jangan menyimpan rahasia, token, atau credential dalam dokumentasi.

## Lisensi

MIT.

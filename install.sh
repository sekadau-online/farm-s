#!/data/data/com.termux/files/usr/bin/bash

echo "📦 Memulai instalasi Log Tanaman Anggur di Termux..."

# Update sistem
pkg update -y && pkg upgrade -y

# Install paket yang dibutuhkan
pkg install -y python nano termux-open

# Buat direktori untuk aplikasi
mkdir -p ~/anggur-log
cd ~/anggur-log

# Unduh file HTML
cat > log-anggur.html <<'EOF'
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Log Perawatan Tanaman Anggur</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: #f4f6f7;
      padding: 20px;
    }
    h1 {
      text-align: center;
      color: #2c3e50;
    }
    form {
      background: #ffffff;
      padding: 15px;
      border-radius: 8px;
      box-shadow: 0 0 5px rgba(0,0,0,0.1);
      margin-bottom: 20px;
    }
    label {
      display: block;
      margin-top: 10px;
    }
    input, textarea {
      width: 100%;
      padding: 8px;
      margin-top: 4px;
      box-sizing: border-box;
    }
    button {
      margin-top: 15px;
      padding: 10px 20px;
      background-color: #27ae60;
      color: white;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      margin-right: 10px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      background: #ffffff;
    }
    th, td {
      border: 1px solid #ccc;
      padding: 10px;
    }
    th {
      background-color: #2ecc71;
      color: white;
    }
    tr:nth-child(even) {
      background-color: #f9f9f9;
    }
  </style>
</head>
<body>

<h1>Log Perawatan Tanaman Anggur</h1>

<form id="logForm">
  <label for="tanggal">Tanggal:</label>
  <input type="date" id="tanggal" required>

  <label for="kegiatan">Kegiatan:</label>
  <input type="text" id="kegiatan" required>

  <label for="produk">Produk/Pupuk:</label>
  <input type="text" id="produk">

  <label for="dosis">Dosis/Keterangan:</label>
  <input type="text" id="dosis">

  <label for="catatan">Catatan Kondisi Tanaman:</label>
  <textarea id="catatan" rows="2"></textarea>

  <button type="submit">Tambah ke Log</button>
  <button type="button" onclick="downloadJSON()">Simpan ke JSON</button>
  <button type="button" onclick="document.getElementById('fileInput').click()">Impor dari JSON</button>
</form>

<input type="file" id="fileInput" style="display:none;" accept=".json" onchange="importFromJSON(event)">

<table id="logTable">
  <thead>
    <tr>
      <th>Tanggal</th>
      <th>Kegiatan</th>
      <th>Produk/Pupuk</th>
      <th>Dosis/Keterangan</th>
      <th>Catatan</th>
    </tr>
  </thead>
  <tbody></tbody>
</table>

<script>
  const dataLog = [];

  const form = document.getElementById('logForm');
  const tbody = document.querySelector('#logTable tbody');

  form.addEventListener('submit', function (e) {
    e.preventDefault();

    const tanggal = document.getElementById('tanggal').value;
    const kegiatan = document.getElementById('kegiatan').value;
    const produk = document.getElementById('produk').value;
    const dosis = document.getElementById('dosis').value;
    const catatan = document.getElementById('catatan').value;

    const entry = { tanggal, kegiatan, produk, dosis, catatan };
    dataLog.push(entry);
    appendToTable(entry);
    form.reset();
  });

  function appendToTable(entry) {
    const row = tbody.insertRow();
    row.innerHTML = `
      <td>${entry.tanggal}</td>
      <td>${entry.kegiatan}</td>
      <td>${entry.produk}</td>
      <td>${entry.dosis}</td>
      <td>${entry.catatan}</td>
    `;
  }

  function downloadJSON() {
    const blob = new Blob([JSON.stringify(dataLog, null, 2)], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'log_tanaman_anggur.json';
    a.click();
    URL.revokeObjectURL(url);
  }

  function importFromJSON(event) {
    const file = event.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = function (e) {
      try {
        const imported = JSON.parse(e.target.result);
        if (Array.isArray(imported)) {
          imported.forEach(entry => {
            dataLog.push(entry);
            appendToTable(entry);
          });
        } else {
          alert("File JSON tidak valid!");
        }
      } catch (err) {
        alert("Gagal membaca file JSON.");
      }
    };
    reader.readAsText(file);
  }
</script>

</body>
</html>
EOF

# Jalankan server Python
echo "🌐 Menjalankan server di http://localhost:8080..."
python -m http.server 8080 &

# Tunggu server aktif, lalu buka otomatis di browser Android
sleep 3
termux-open http://localhost:8080/log-anggur.html

echo "✅ Sistem log tanaman anggur siap digunakan!"

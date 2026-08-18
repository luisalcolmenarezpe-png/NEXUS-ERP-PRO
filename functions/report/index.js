/* Server de reportes Express */
const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const app = express();
app.use(express.json());

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

function toCSV(rows) {
  if (!rows || rows.length === 0) return '';
  const cols = Object.keys(rows[0]);
  const header = cols.join(',');
  const lines = rows.map(r => cols.map(c => `"${String(r[c] ?? '')}"`).join(','));
  return [header, ...lines].join('\n');
}

app.get('/report/invoices', async (req, res) => {
  try {
    const { data, error } = await supabase.from('invoices').select('id,customer_id,total,status,created_at');
    if (error) return res.status(500).json({ error: error.message });
    const csv = toCSV(data || []);
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="invoices_report.csv"');
    res.send(csv);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const port = process.env.PORT || 4000;
app.listen(port, () => console.log(`Report server on ${port}`));

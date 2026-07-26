import { query } from './src/config/db.js';
import * as https from 'https';

async function updateDurations() {
  const { rows } = await query(`SELECT id, file_url FROM content WHERE content_type = 'video'`);
  for (const row of rows) {
    if (row.file_url.includes('youtube.com') || row.file_url.includes('youtu.be')) {
      const minutes = await new Promise<number>((resolve) => {
        https.get(row.file_url, (res) => {
          let data = '';
          res.on('data', chunk => data += chunk);
          res.on('end', () => {
            const match = data.match(/<meta itemprop="duration" content="([^"]+)">/);
            if (match && match[1]) {
              let m = 0;
              const h = match[1].match(/(\d+)H/);
              const min = match[1].match(/(\d+)M/);
              const s = match[1].match(/(\d+)S/);
              if (h) m += parseInt(h[1]) * 60;
              if (min) m += parseInt(min[1]);
              if (s && parseInt(s[1]) > 30) m += 1;
              resolve(m);
            } else {
              resolve(0);
            }
          });
        }).on('error', () => resolve(0));
      });
      await query(`UPDATE content SET duration_minutes = $1 WHERE id = $2`, [minutes, row.id]);
      console.log(`Updated video ${row.id} to ${minutes} mins`);
    }
  }
  process.exit(0);
}
updateDurations();

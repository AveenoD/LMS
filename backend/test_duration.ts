import * as https from 'https';

export function fetchYoutubeDuration(url: string): Promise<number | null> {
  return new Promise((resolve) => {
    try {
      if (!url.includes('youtube.com') && !url.includes('youtu.be')) {
        return resolve(null);
      }
      https.get(url, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          const match = data.match(/<meta itemprop="duration" content="([^"]+)">/);
          if (match && match[1]) {
            const isoDuration = match[1]; // e.g., PT3H24M58S or PT4M15S
            let minutes = 0;
            const hoursMatch = isoDuration.match(/(\d+)H/);
            const minutesMatch = isoDuration.match(/(\d+)M/);
            const secondsMatch = isoDuration.match(/(\d+)S/);
            
            if (hoursMatch) minutes += parseInt(hoursMatch[1]) * 60;
            if (minutesMatch) minutes += parseInt(minutesMatch[1]);
            // Optionally add seconds rounding, but integer minutes is fine
            if (secondsMatch && parseInt(secondsMatch[1]) > 30) minutes += 1;
            
            resolve(minutes);
          } else {
            resolve(null);
          }
        });
      }).on('error', () => resolve(null));
    } catch (e) {
      resolve(null);
    }
  });
}

fetchYoutubeDuration('https://www.youtube.com/watch?v=dQw4w9WgXcQ').then(m => console.log('Duration minutes:', m));

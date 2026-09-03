module.exports = {
  apps: [
    {
      name: 'campus-api',
      // Run compiled JS from dist (built via `npm run build`).
      script: 'dist/app.js',
      cwd: __dirname,
      instances: 1,
      exec_mode: 'fork',
      watch: false,
      env: {
        NODE_ENV: 'development',
      },
    },
  ],
};

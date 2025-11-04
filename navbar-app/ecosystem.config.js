module.exports = {
  apps: [
    {
      name: 'callback-server',
      script: './callback-server.js',
      env: {
        PORT: 5000,
        HOST: '0.0.0.0',
        SPA_BASE_URL: 'http://localhost:3001',
        CALLBACK_BASE_URL: 'http://localhost:5000',
        AUTHORIZE_URI: 'http://localhost:3000/authorize'
      }
    }
  ]
};

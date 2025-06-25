module.exports = {
  env: {
    browser: false,
    commonjs: true,
    es2021: true,
    node: true, // Questo aggiunge automaticamente setInterval, clearInterval, etc.
  },
  extends: 'eslint:recommended',
  parserOptions: {
    ecmaVersion: 2021,
    sourceType: 'script'
  },
  overrides: [
    {
      files: ['**/*.js'], // Corretto da '*/.js' a '**/*.js'
      rules: {
        'no-case-declarations': 'off',
        'no-undef': 'error',
        'no-unused-vars': 'warn',
        'no-console': 'off'
      },
      globals: {
        // Node-RED globals
        RED: 'readonly',
        msg: 'writable',
        flow: 'readonly',
        global: 'readonly',
        context: 'readonly',
        node: 'writable',
        config: 'readonly',
        transport: 'readonly',
        s7ConnOpts: 'writable',
        connOpts: 'writable',

        // Funzioni personalizzate
        validateTSAP: 'readonly',

        // Se hai altre funzioni personalizzate, aggiungile qui
      }
    }
  ],
  rules: {}
};
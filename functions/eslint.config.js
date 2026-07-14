module.exports = [
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "commonjs",
      globals: {
        console: "readonly",
        exports: "writable",
        module: "writable",
        require: "readonly",
      },
    },
    rules: {
      "comma-dangle": ["error", "always-multiline"],
      "object-curly-spacing": ["error", "never"],
      quotes: ["error", "double", {avoidEscape: true}],
      semi: ["error", "always"],
    },
  },
];

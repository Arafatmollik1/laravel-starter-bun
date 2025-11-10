# Using Bun with Laravel Starter

This project uses [Bun](https://bun.sh) as the JavaScript runtime and package manager instead of Node.js and npm. Bun provides faster installation, better performance, and built-in TypeScript support.

## Prerequisites

### Installing Bun

Install Bun using one of the following methods:

**macOS/Linux:**
```bash
curl -fsSL https://bun.sh/install | bash
```

**Windows:**
```powershell
powershell -c "irm bun.sh/install.ps1 | iex"
```

**Using npm (if you have Node.js installed):**
```bash
npm install -g bun
```

**Using Homebrew (macOS):**
```bash
brew install bun
```

After installation, restart your terminal or run:
```bash
source ~/.bashrc  # or ~/.zshrc depending on your shell
```

Verify the installation:
```bash
bun --version
```

## Project Setup

### Initial Setup

1. **Install PHP dependencies:**
   ```bash
   composer install
   ```

2. **Install JavaScript dependencies:**
   ```bash
   bun install
   ```
   
   This will:
   - Install all dependencies from `package.json`
   - Create a `bun.lockb` file (Bun's lockfile, similar to `package-lock.json`)
   - Install dependencies much faster than npm

3. **Set up environment:**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. **Run migrations:**
   ```bash
   php artisan migrate
   ```

5. **Build assets:**
   ```bash
   bun run build
   ```

Or use the Composer setup script that does all of the above:
```bash
composer run setup
```

## Development

### Running the Development Server

Start the Laravel development server with Vite hot-reloading:

```bash
composer run dev
```

This command runs:
- Laravel Octane server with FrankenPHP and HTTPS enabled (`php artisan octane:start --server=frankenphp --https`)
- Queue worker (`php artisan queue:listen`)
- Laravel Pail for logs (`php artisan pail`)
- Vite dev server (`bun run dev`)

All processes run concurrently with colored output.

**Access your application at:** `https://localhost:8000` (HTTPS is enabled by default)

### Laravel Octane & FrankenPHP

This project uses [Laravel Octane](https://laravel.com/docs/octane) with [FrankenPHP](https://frankenphp.dev/) as the application server. Octane provides high-performance, persistent application state, while FrankenPHP offers modern web features like HTTP/2, HTTP/3, early hints, and advanced compression.

**Benefits:**
- **Performance**: Significantly faster than the traditional PHP development server
- **Persistent State**: Application state persists between requests
- **Modern Features**: HTTP/2, HTTP/3, Brotli/Zstandard compression support
- **Worker Processes**: Multiple workers handle requests concurrently

**Starting Octane manually:**
```bash
php artisan octane:start --server=frankenphp
```

**Starting Octane with watch mode (auto-reload on file changes):**
```bash
php artisan octane:start --server=frankenphp --watch
```

**Stopping Octane:**
Press `Ctrl+C` or run:
```bash
php artisan octane:stop
```

**Configuration:**
- Octane configuration: `config/octane.php`
- Default server: FrankenPHP (can be changed via `OCTANE_SERVER` env variable)
- Default port: 8000 (can be changed via `--port` option)
- HTTPS: Enabled by default in development (access at `https://localhost:8000`)
- Host: Set to `localhost` for proper HTTPS certificate generation

**Starting Octane without HTTPS (if needed):**
```bash
php artisan octane:start --server=frankenphp
```

### Running Individual Commands

**Start Vite dev server only:**
```bash
bun run dev
```

**Build for production:**
```bash
bun run build
```

**Build with SSR (Server-Side Rendering):**
```bash
bun run build:ssr
```

**Run development with SSR:**
```bash
composer run dev:ssr
```

## Available Scripts

All scripts in `package.json` work with Bun. Use `bun run <script>` instead of `npm run <script>`:

| Command | Description |
|---------|-------------|
| `bun run dev` | Start Vite development server with hot-reloading |
| `bun run build` | Build assets for production |
| `bun run build:ssr` | Build assets with SSR support |
| `bun run format` | Format code with Prettier |
| `bun run format:check` | Check code formatting without fixing |
| `bun run lint` | Run ESLint and auto-fix issues |
| `bun run types` | Type-check TypeScript without emitting files |

## Package Management

### Installing Packages

**Install a dependency:**
```bash
bun add <package-name>
```

**Install a dev dependency:**
```bash
bun add -d <package-name>
```

**Install all dependencies:**
```bash
bun install
```

### Removing Packages

```bash
bun remove <package-name>
```

### Updating Packages

```bash
bun update
```

### Running Packages

Bun can run packages directly without installing them globally (similar to `npx`):

```bash
bunx <package-name>
```

For example:
```bash
bunx concurrently --help
```

## Key Differences from npm

1. **Speed**: Bun installs packages significantly faster than npm
2. **Lockfile**: Bun uses `bun.lockb` (binary format) instead of `package-lock.json`
3. **Runtime**: Bun can run JavaScript/TypeScript files directly without compilation
4. **Compatibility**: Bun is compatible with npm packages and scripts

## Troubleshooting

### Clear Bun Cache

If you encounter issues, try clearing Bun's cache:

```bash
bun pm cache rm
```

### Reinstall Dependencies

Remove `node_modules` and `bun.lockb`, then reinstall:

```bash
rm -rf node_modules bun.lockb
bun install
```

### Check Bun Version

Ensure you're using a recent version:

```bash
bun --version
```

Update Bun if needed:
```bash
bun upgrade
```

### Octane/FrankenPHP Warnings

**Caddyfile formatting warning:**
```
WARN  Caddyfile input is not formatted; run 'caddy fmt --overwrite' to fix inconsistencies.
```
This warning is harmless and can be ignored. FrankenPHP generates the Caddyfile automatically.

**HTTP/2 and HTTP/3 warnings:**
```
WARN  HTTP/2 skipped because it requires TLS.
WARN  HTTP/3 skipped because it requires TLS.
```
These warnings are expected when running without HTTPS. Your application works perfectly fine with HTTP/1.1. To enable HTTP/2/3, use the `--https` flag when starting Octane.

**SSL Protocol Error (ERR_SSL_PROTOCOL_ERROR):**
If you encounter SSL errors when accessing `https://localhost:8000`, try:

1. **Ensure you're using `localhost` not `127.0.0.1`** - FrankenPHP's automatic certificate generation works best with `localhost`
2. **Clear browser cache** - Sometimes browsers cache SSL errors
3. **Accept the self-signed certificate** - Click "Advanced" → "Proceed to localhost" when prompted
4. **Check if certificates are being generated** - Look for certificate files in `~/.local/share/mkcert` or similar locations
5. **Fall back to HTTP** - If HTTPS continues to cause issues, remove `--https` flag and use `http://localhost:8000`

## File Structure

- `package.json` - JavaScript dependencies and scripts (works with Bun)
- `bun.lockb` - Bun's lockfile (binary, auto-generated, git-ignored)
- `node_modules/` - Installed packages (git-ignored)
- `vite.config.ts` - Vite configuration (works with Bun)
- `config/octane.php` - Laravel Octane configuration

## Notes

- Bun maintains compatibility with npm, so all existing npm scripts work without modification
- The `node_modules` directory is still used (Bun maintains npm compatibility)
- TypeScript files can be run directly with Bun: `bun run file.ts`
- Bun includes a built-in test runner, bundler, and package manager

## Resources

- [Bun Documentation](https://bun.sh/docs)
- [Bun GitHub](https://github.com/oven-sh/bun)
- [Laravel Vite Plugin](https://laravel.com/docs/vite)
- [Laravel Octane Documentation](https://laravel.com/docs/octane)
- [FrankenPHP Documentation](https://frankenphp.dev/docs)


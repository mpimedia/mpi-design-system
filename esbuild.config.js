const esbuild = require('esbuild')
const path = require('path')

// Check if we're in watch mode
const watchMode = process.argv.includes('--watch')

// Common build options
const buildOptions = {
  bundle: true,
  sourcemap: true,
  format: 'iife',
  alias: {
    'mpi_design_system': path.resolve(__dirname, 'app/javascript/mpi_design_system')
  },
  plugins: []
}

async function build() {
  try {
    if (watchMode) {
      const ctx = await esbuild.context({
        ...buildOptions,
        entryPoints: ['spec/dummy/app/javascript/application.js'],
        outfile: 'spec/dummy/app/assets/builds/application.js',
      })

      await ctx.watch()
      console.log('Watching for changes...')
    } else {
      await esbuild.build({
        ...buildOptions,
        entryPoints: ['spec/dummy/app/javascript/application.js'],
        outfile: 'spec/dummy/app/assets/builds/application.js',
      })
      console.log('Build complete')
    }
  } catch (error) {
    console.error('Build failed:', error)
    process.exit(1)
  }
}

build()

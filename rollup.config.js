import svelte from 'rollup-plugin-svelte';
import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import livereload from 'rollup-plugin-livereload';
import {terser} from 'rollup-plugin-terser';
import css from 'rollup-plugin-css-only';
import sveltePreprocess from 'svelte-preprocess';
import replace from '@rollup/plugin-replace';

const production = !process.env.ROLLUP_WATCH;

function serve() {
    let server;

    function toExit() {
        if (server) server.kill(0);
    }

    return {
        writeBundle() {
            if (server) return;
            server = require('child_process').spawn('npm', ['run', 'start'], {
                stdio: ['ignore', 'inherit', 'inherit'],
                shell: true
            });

            process.on('SIGTERM', toExit);
            process.on('exit', toExit);
        }
    };
}

export default {
    input: 'src/main.js',
    output: {
        sourcemap: true,
        format: 'iife',
        name: 'app',
        file: 'public/build/pcd_form.js'
    },
    plugins: [
        replace({
            include: ["src/**/*.svelte"],
            preventAssignment: true,
            values: {
                "process.env.pci_address_prod":  "'" + (process.env.pci_address || (production ? "https://api.pcivault.io" : "")) + "'",
                "process.env.pci_address_testing":  "'" + (process.env.pci_address || (production ? "https://api-stage.pcivault.io" : "")) + "'",
            }
        }),
        svelte({
            compilerOptions: {
                dev: !production
            },
            preprocess: sveltePreprocess({
                postcss: true,
            }),
        }),
        css({output: 'pcd_form.css'}),

        resolve({
            browser: true,
            dedupe: ['svelte']
        }),
        commonjs(),

        !production && serve(),
        !production && livereload('public'),
        production && terser()
    ],
    watch: {
        clearScreen: false
    }
};

import App from './App.svelte'

const ach = (element, settings) => new App({
  target: element || document.body,
  props: {
    settings: settings
  }
})

window.ach_form = ach

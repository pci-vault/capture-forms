import App from './App.svelte'

const ach = (element, settings) => new App({
  target: element || document.body,
  props: {
    settings: settings,
    form: "ach"
  }
})

window.ach_form = ach

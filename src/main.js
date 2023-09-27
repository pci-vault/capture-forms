import App from './App.svelte'

const pcd = (element, settings) => new App({
  target: element || document.body,
  props: {
    settings: settings
  }
})

window.pcd_form = pcd

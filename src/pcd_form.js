import App from './App.svelte'

const pcd = (element, settings) => new App({
  target: element || document.body,
  props: {
    settings: settings,
    form: "pcd"
  }
})

window.pcd_form = pcd

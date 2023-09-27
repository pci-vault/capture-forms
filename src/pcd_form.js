import App from './pcd_form.svelte'

const pcd = (element, settings) => new App({
  target: element || document.body,
  props: {
    settings: settings,
  }
})

window.pcd_form = pcd

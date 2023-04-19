<script>
  import ACHForm from "./lib/ACHForm.svelte";

  export let settings = {}
</script>

<main>
  <ACHForm {...settings} />
</main>

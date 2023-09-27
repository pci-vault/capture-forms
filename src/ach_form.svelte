<script>
    import ACHForm from "./ACH/ACHForm.svelte";

    export let settings = {}
</script>

<main>
  <ACHForm {...settings}/>
</main>

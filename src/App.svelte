<script>
    import CreditCard from "./CreditCard/CreditCardForm.svelte";

    export let settings = {}
    export let form
</script>

<main>
  {#if form === "pcd" }
    <CreditCard {...settings}/>
  {:else if form === "" }

  {:else}
    Unknown Form: {form}
  {/if}
</main>

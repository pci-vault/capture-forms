<script>
    import CreditCard from "./CreditCard/CreditCardForm.svelte";
    import ACHForm from "./ACH/ACHForm.svelte";

    export let settings = {}
    export let form
</script>

<main>
  {#if form === "pcd" }
    <CreditCard {...settings}/>
  {:else if form === "ach" }
    <ACHForm {...settings}/>
  {:else}
    Unknown Form: {form}
  {/if}
</main>

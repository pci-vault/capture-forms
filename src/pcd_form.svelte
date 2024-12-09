<script>
    import CreditCard from "./CreditCard/CreditCardForm.svelte";

    export let settings = {};
</script>

<main>
  <CreditCard {...settings} />
</main>

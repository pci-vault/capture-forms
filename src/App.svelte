<script>
  import CreditCard from "./lib/CreditCardForm.svelte";

  export let settings = {}
</script>

<main>
  <CreditCard {...settings} />
</main>

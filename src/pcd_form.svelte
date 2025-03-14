<script>
    import CreditCardForm from "./CreditCard/CreditCardForm.svelte";

    export let settings = {};
</script>

<main>
  <CreditCardForm
    pci_address_prod={process.env.pci_address_prod}
    pci_address_testing={process.env.pci_address_testing}
    {...settings}
  />
</main>

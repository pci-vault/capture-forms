<script>
    import ACHForm from "./ACH/ACHForm.svelte";

    export let settings = {}
</script>

<main>
  <ACHForm
    pci_address_prod={process.env.pci_address_prod}
    pci_address_testing={process.env.pci_address_testing}
    {...settings}
  />
</main>

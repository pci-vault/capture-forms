<script>
    import ACHForm from "./ACH/ACHForm.svelte";

    export let settings = {};
    export let onSubmit;
    export let onReset;
</script>

<main>
  <ACHForm
    pci_address_prod={process.env.pci_address_prod}
    pci_address_testing={process.env.pci_address_testing}
    bind:submit={onSubmit}
    bind:reset={onReset}
    {...settings}
  />
</main>

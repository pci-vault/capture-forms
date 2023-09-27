<script>
    import {createEventDispatcher} from "svelte";

    export let value

    const dispatch = createEventDispatcher();

    function click() {
        dispatch('click', value)
    }
</script>

<div class="key" on:click={click}>
  {value}
</div>

<style>
    .key {
        display: flex;
        justify-content: space-around;
        align-items: center;

        box-sizing: content-box;
        border-radius: 8px;
        height: 64px;
        width: 64px;
        padding: 8px;

        background-color: gray;
        color: white;
        font-size: 24px;

        cursor: pointer;
    }
</style>

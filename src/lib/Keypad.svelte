<script>
    import Key from "./Key.svelte";
    import {createEventDispatcher} from "svelte";

    export let number = ""

    let keys = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
    let currentIndex = keys.length, randomIndex;

    // shuffle array
    // https://stackoverflow.com/a/2450976/921684
    while (currentIndex !== 0) {
        // Pick a remaining element.
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex--;

        // And swap it with the current element.
        [keys[currentIndex], keys[randomIndex]] = [
            keys[randomIndex], keys[currentIndex]];
    }

    const dispatch = createEventDispatcher();

    const close = () => {
        dispatch("close")
    }
</script>

<div class="overlay">
  <div class="dialog">
    <div class="num-display">
      {number}
    </div>
    <div class="pad">
      {#each keys.slice(0, keys.length - 1) as v}
        <Key value="{v}" on:click={() => number+=v}/>
      {/each}
      <div></div>
      <Key value="{keys[keys.length - 1]}" on:click={() => number+=keys[keys.length - 1]}/>
      <div></div>
      <div class="bottom-btn btn-cancel" on:click={() => {number = ""; close()}}>CANCEL</div>
      <div class="bottom-btn btn-back" on:click={() => number = number.substring(0, number.length - 1)}>&lt</div>
      <div class="bottom-btn btn-done" on:click={close}>DONE</div>
    </div>
  </div>
</div>

<style>
    .overlay {
        position: absolute;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0;
        height: 100%;
        width: 100%;
        background-color: rgba(100, 100, 100, 0.27);
        z-index: 1000;

        display: flex;
        justify-content: space-around;
        align-items: center;
    }

    .num-display {
        height: 56px;
        border: 1px solid gray;
        border-radius: 5px;
        margin-bottom: 16px;
        text-align: center;
        font-size: 24px;
        vertical-align: middle;
        line-height: 56px;
        color: black;
    }

    .dialog {
        background-color: white;
        padding: 16px;
        box-shadow: 0 10px 20px -7px rgba(32, 56, 117, 0.35);
        border-radius: 8px;
    }

    .pad {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 16px;
    }

    .bottom-btn {
        display: flex;
        justify-content: space-around;
        align-items: center;

        box-sizing: content-box;
        border-radius: 8px;
        width: 64px;
        padding: 8px;

        color: white;
        font-size: 18px;

        cursor: pointer;
    }

    .btn-cancel {
        background-color: #ca0909;
    }

    .btn-back {
        background-color: #e6cd19;
        color: black;
    }

    .btn-done {
        background-color: #12B331;
    }
</style>

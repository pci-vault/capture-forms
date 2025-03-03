<script>
    import {fly} from 'svelte/transition';

    export let asset_url = "/"
    export let cardType = "other"
    export let cardNumberMask = "#### #### #### ####"
    export let isCardFlipped = false
    export let cardNumber = ""
    export let hideCardNumber = false
    export let cardName = ""
    export let expiry = ""
    export let cardCvv = ""
    export let hideCvv = false

    let cardWidth = 100

    $: iconURL = `${asset_url}/` + (cardType === "other" ? "card-icons/pcivault.svg" : `card-icons/${cardType}.svg`)
    $: fontSize = 0.05 * cardWidth;
    $: fontSizeSmall = 0.6 * fontSize;
    $: fontSizeBig = 1.4 * fontSize;
</script>

<div id="pcivault-pcd-card" class="card" bind:clientWidth={cardWidth} style="font-size:{fontSize}px;">
  <div id="pcivault-pcd-card-front" class="card-side front" class:flipped={isCardFlipped}>
    <div id="pcivault-pcd-card-front-image-cover" class="card-img-cover">
      <img id="pcivault-pcd-card-front-image" alt="card" class="card-img" src={`${asset_url}/card.svg`}>
    </div>
    <div id="pcivault-pcd-card-front-grid" class="card-front-grid">
      <img id="pcivault-pcd-card-chip"
           alt="card chip"
           src={`${asset_url}/chip.svg`}
           class="card-item-chip">
      {#if iconURL && !iconURL.includes("other")}
        {#each [iconURL] as iconURL (iconURL)}
          <img in:fly={{y:-20}} out:fly={{y:20}} id="pcivault-pcd-{cardType}-logo" src={iconURL} alt=""
               class="card-item-logo">
        {/each}
      {/if}
      <div id="pcivault-pcd-card-number" class="card-number">
        {#each cardNumberMask as n, index (index)}
          {#if hideCardNumber && index >= (cardNumber.length - 4)}
            <span class="card-number-item">{cardNumber[index]}</span>
          {:else if !hideCardNumber && cardNumber.length > index}
            <span class="card-number-item">{cardNumber[index]}</span>
          {:else}
            <span class="card-number-item">{n}</span>
          {/if}
        {/each}
      </div>
      <div id="pcivault-pcd-card-name" class="card-name">
        <div id="pcivault-pcd-card-name-label" style="font-size:{fontSizeSmall}px;">Card Holder</div>
        <div id="pcivault-pcd-card-name-value" style="font-size:{fontSize}px;">
          <span>{cardName || "FULL NAME"}</span>
        </div>
      </div>
      <div id="pcivault-pcd-card-date" class="card-date">
        <div id="pcivault-pcd-card-date-label" style="font-size:{fontSizeSmall}px;">Expires</div>
        <div id="pcivault-pcd-card-date-value" style="font-size:{fontSize}px;">
          <span>{expiry}</span>
        </div>
      </div>
    </div>
  </div>
  <div id="pcivault-pcd-card-back" class="card-side back" class:flipped={!isCardFlipped}>
    <div id="pcivault-pcd-card-back-image-cover" class="card-img-cover">
      <img id="pcivault-pcd-card-back-iamge" alt="card" class="card-img" src={`${asset_url}/card.svg`}>
    </div>
    <div id="pcivault-pcd-card-back-box" class="card-back">
      <div id="pcivault-pcd-card-mag-stripe" class="mag-stripe"></div>
      <div id="pcivault-pcd-card-siganture-band" class="signature-band">
        <div id="pcivault-pcd-card-siganture" class="signature-item" style="font-size:{fontSizeBig}px;">
          <span>{cardName}</span></div>
        <div id="pcivault-pcd-card-cvv" class="cvv-item">
          {#if hideCvv}
            {#each cardCvv as cvvItem}*{/each}
          {:else}
            {cardCvv}
          {/if}
        </div>
      </div>
      <div id="pcivault-pcd-card-logo-back" class="card-logo-back">
        <img src={iconURL} alt="">
      </div>
    </div>
  </div>
</div>

<style>
    @import url("https://fonts.googleapis.com/css?family=Source+Code+Pro:400,500,600,700|Source+Sans+Pro:400,600,700&display=swap");

    @font-face {
        font-family: "High Summit";
        src: url("/assets/high-summit.regular.ttf")
    }

    .card {
        aspect-ratio: 1.59;
        max-width: 464px;
        min-width: 256px;
        position: relative;

        width: 90%;
        margin: auto;

        color: white;
        text-shadow: 7px 6px 10px rgba(14, 42, 90, 0.8);
        font-family: "Source Code Pro", monospace;
    }

    .card-side {
        position: absolute;
        top: 0;
        left: 0;
        bottom: 0;
        right: 0;
        height: 100%;
        box-shadow: 0 20px 60px 0 rgba(14, 42, 90, 0.55);
        border-radius: 16px;
        backface-visibility: hidden;
    }

    .card-side.front {
        transform: perspective(2000px) rotateY(0deg) rotateX(0deg) rotateZ(0deg);
        transform-style: preserve-3d;
        transition: all 0.8s cubic-bezier(0.71, 0.03, 0.56, 0.85);
    }

    .card-side.front.flipped {
        transform: perspective(1000px) rotateY(180deg) rotateX(0deg) rotateZ(0deg);
    }

    .card-side.back {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;

        transform: perspective(1000px) rotateY(0deg) rotateX(0deg) rotateZ(0deg);
        transition: all 0.8s cubic-bezier(0.71, 0.03, 0.56, 0.85);
    }

    .card-side.back.flipped {
        transform: perspective(2000px) rotateY(-180deg) rotateX(0deg) rotateZ(0deg);
    }

    .card-img-cover {
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        border-radius: 16px;
        overflow: hidden;
        z-index: 1;
    }

    .card-img {
        height: 100%;
        width: 100%;
        object-fit: cover;
    }

    .card-front-grid {
        display: grid;
        align-content: stretch;
        height: 100%;

        grid-template-columns: 5% repeat(3, 30%) 5%;
        grid-template-rows: 5% repeat(3, 30%) 5%;

        position: relative;
        z-index: 2;
    }

    .card-item-chip {
        grid-column: 2;
        grid-row: 2;

        width: 60%;
        place-self: center left;
    }

    .card-item-logo {
        grid-column: 4;
        grid-row: 2;

        width: 85%;
        place-self: center right;
    }

    .card-number {
        grid-column-start: 2;
        grid-column-end: 5;
        grid-row: 3;
        place-self: center;

        width: 100%;
        display: flex;
        justify-content: space-around;
    }

    .card-number-item {
        display: inline-block;
        width: 4%;
        text-align: center;
    }

    .card-name {
        grid-column-start: 2;
        grid-column-end: 4;
        grid-row: 4;
        place-self: center left;

        font-size: 18px;
    }

    .card-date {
        grid-column: 4;
        grid-row: 4;
        place-self: center right;

        font-size: 18px;
    }

    .card-back {
        display: flex;
        flex-direction: column;
        justify-content: space-around;

        position: relative;
        z-index: 2;
        height: 100%;
    }

    .mag-stripe {
        background: rgba(0, 0, 19, 0.8);
        height: 20%;
        width: 100%;
    }

    .signature-band {
        display: flex;
        padding: 0 5% 0 5%;

        height: 20%;
        width: 90%;
    }

    .signature-item {
        display: flex;
        align-items: center;
        width: 80%;

        background-color: #e6e6b1;
        border-radius: 4px 0 0 4px;
        box-shadow: 0 10px 20px -7px rgba(32, 56, 117, 0.35);

        font-family: "High Summit", sans-serif;
        text-align: left;
        font-style: italic;
        color: #1a3b5d;
        text-shadow: none;

        padding-left: 1rem;

        overflow: hidden;
    }

    .cvv-item {
        display: flex;
        align-items: center;
        justify-content: end;
        width: 20%;

        background: #fff;
        text-align: right;
        padding-right: 3%;
        color: #1a3b5d;
        text-shadow: none;

        border-radius: 0 4px 4px 0;
        box-shadow: 0 10px 20px -7px rgba(32, 56, 117, 0.35);
    }

    .card-logo-back {
        display: flex;
        justify-content: end;
        padding-right: 5%;

        height: 15%;
    }
</style>

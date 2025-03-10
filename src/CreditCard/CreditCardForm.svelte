<!--suppress CssUnknownTarget -->
<script>
    /*
    Ported from https://svelte.dev/repl/153bbcac104f42569bcf82a1fb4ad94e?version=3.12.1
    */

  import {onMount, tick} from 'svelte';
  import axios from "axios";
  import luhn from "luhn-js"
  import {IconClipboard, IconEye, IconClipboardCheck} from "@tabler/icons-svelte";

    import CreditCard from "./CreditCard.svelte";
    import Keypad from "../lib/Keypad.svelte";

    export let pci_address_prod = "";
    export let pci_address_testing = ""

    export let testing = false
    export let submit_url = ""
    export let submit_secret = ""

    export let retrieve_url = ""
    export let retrieve_secret = ""
    export let token = ""

    export let success_callback = function () {}
    export let error_callback = function () {}
    export let extra_data = {}
    export let reference = null

    export let show_card = true
    export let disable_luhn = false
    export let force_keypad = false
    export let strip_spaces = false

    export let field_options = {}
    let fieldSettings = {
        card_number: {
            visible: field_options.card_number?.visible ?? true,
            validate: field_options.card_number?.validate ?? true,
        },
        card_holder: {
            visible: field_options.card_holder?.visible ?? true,
            validate: field_options.card_holder?.validate ?? true,
        },
        expiry: {
            visible: field_options.expiry?.visible ?? true,
            validate: field_options.expiry?.validate ?? true,
        },
        cvv: {
            visible: field_options.cvv?.visible ?? true,
            validate: field_options.cvv?.validate ?? true,
        }
    }

    const validate_field = (entry) => fieldSettings[entry].validate && fieldSettings[entry].visible

    let validate = false
    let cardName = ""
    let cardNumber = ""
    let cardMonth = ""
    let cardYear = ""
    let cardCvv = ""
    let extraData = {}

    let expiry;
    $: expiry = (cardMonth || "MM") + "/" + (cardYear ? String(cardYear).slice(2, 4) : "YY")

    let amexCardMask = "#### ###### #####"
    let otherCardMask = "#### #### #### ####"
    let cardType;
    let isCardFlipped = false
    let cardNumberMask;
    let result;
    let cardKeypad = false;

    let isCardRetrieved;
    let isRetrieval;
    $: isRetrieval = retrieve_url.length > 0 && submit_url.length === 0
    $: show_card = (!isRetrieval && show_card) || (isRetrieval && isCardRetrieved )
    
    $: if (isRetrieval) {
      retrieve()
    }

    let cardInputVisible;
    $: cardInputVisible = !isRetrieval;

    onMount(function () {
        window.addEventListener('load', () => document.getElementById("cardNumber").focus())
    })

    let minCardYear = new Date().getFullYear().toString(10)
    $: minCardMonth = cardYear === minCardYear ? new Date().getMonth() + 1 : 1
    $: cardMonth = cardMonth < minCardMonth ? '' : cardMonth

    $: {
        if (cardNumber.match(new RegExp("^3[47]\\d{0,13}")) != null) cardType = "amex";
        else if (cardNumber.match(new RegExp("^5[1-5]")) != null) cardType = "mastercard";
        else if (cardNumber.match(new RegExp("^(?:6011|65\\d{0,2}|64[4-9]\\d?)\\d{0,12}")) != null) cardType = "discover";
        else if (cardNumber.match(new RegExp("^3(?:0([0-5]|9)|[689]\\d?)\\d{0,11}")) != null) cardType = "diners";
        else if (cardNumber.match(new RegExp("^4\\d{0,15}")) != null) cardType = "visa";
        else if (cardNumber.match(new RegExp("^(?:2131|1800)\\d{0,11}")) != null) cardType = "jcb1";
        else if (cardNumber.match(new RegExp("^35\\d{0,2}\\d{0,12}")) != null) cardType = "jcb";
        else if (cardNumber.match(new RegExp("^(?:5[0678]\\d{0,2}|6304|67\\d{0,2})\\d{0,12}")) != null) cardType = "maestro";
        else if (cardNumber.match(new RegExp("^62\\d{0,14}")) != null) cardType = "union";
        else cardType = "other"; // default type

        cardNumberMask = cardType === "amex" || cardType === "jcb1" ? amexCardMask : otherCardMask;
        cardType = cardType === "jcb1" ? "jcb" : cardType;

        // Credit card input masking
        cardNumber = cardNumber.substring(0, cardNumberMask.length).replace(/[^0-9]/g, '')
        for (let index = 0; index < cardNumber.length; index++) {
            if (cardNumberMask[index] === ' ' && cardNumber[index] !== ' ') {
                cardNumber = cardNumber.substring(0, index) + ' ' + cardNumber.substring(index)
            }
        }
        if (cardNumber.substring(cardNumber.length - 1) === ' ') {
            cardNumber = cardNumber.substring(0, cardNumber.length - 1)
        }
        cardNumber = cardNumber.substring(0, cardNumberMask.length).replace(/[^0-9 ]/g, '')
    }

    $: validation_disabled = disable_luhn || !validate
    $: validNumber = validation_disabled || !validate_field("card_number") || (cardNumber.length > 1 && luhn.isValid(cardNumber.replaceAll(' ', '')))
    $: validHolder = validation_disabled || !validate_field("card_holder") || cardName
    $: validMonth = validation_disabled || !validate_field("expiry") || cardMonth
    $: validYear = validation_disabled || !validate_field("expiry") || cardYear
    $: validCVV = validation_disabled || !validate_field("cvv") || cardCvv
    $: allValid = validNumber && validHolder && validMonth && validYear && validCVV

    let pci_address = testing ? pci_address_testing : pci_address_prod

    async function submit() {
        validate = true
        await tick();
        if (!allValid) {
            return
        }

        if (!submit_url || !submit_secret || !submit_url.startsWith("/v1/capture/")) {
            throw new Error("Submit info not set correctly")
        }

        let url = pci_address + submit_url
        let submit_data = {
            ...extra_data,
            "card_number": strip_spaces ? cardNumber.replace(/\s/g, "") : cardNumber,
            "card_holder": cardName,
            "cvv": cardCvv,
            "expiry": expiry,
            "expiry_year": cardYear,
            "expiry_year_short": cardYear.slice(-2),
            "expiry_month": cardMonth,
            "card_type": cardType,
            "last_four": cardNumber.slice(-4),
        }
        axios({
            method: 'post',
            params: reference ? { reference: reference } : undefined,
            'url': url,
            data: submit_data,
            headers: {
                "X-PCIVault-Capture-Secret": submit_secret
            }
        }).then(async function (d) {
            result = "Card successfully captured."
            await tick();
            if (typeof success_callback === 'function') {
                success_callback(d.data, submit_data)
            }
        }).catch(async function (r) {
            result = "An error occurred, refresh the page and try again."
            await tick();
            if (typeof error_callback === 'function') {
                error_callback({code: r.response.status, data: r.response.data}, submit_data)
            }
        })
    }

    async function retrieve() {
      await tick();

      if (!retrieve_url || !retrieve_secret || !token || !retrieve_url.startsWith("/v1/retrieve/")) {
          throw new Error("Retrieve info not set correctly")
      }

      const url = pci_address + retrieve_url
      const params = {token: token}
      if (reference) {
        params["reference"] = reference;
      }

      axios({
        method: 'get',
        params: params,
        'url': url,
        headers: {
          "X-PCIVault-Retrieve-Secret": retrieve_secret
        }
      }).then(async function (response) {
        const data = { ...response.data };

        const cardNumberAliases = ["card_number", "number", "n", "pan"];
        for (const cardNumberAlias of cardNumberAliases) {
          cardNumber = data[cardNumberAlias];
          if (cardNumber) {
            cardNumber = cardNumber.toString();
          }
          if (cardNumber && cardNumber.length > 0) {
            delete data[cardNumberAlias];
            break;
          }
        }
        delete data["last_four"];

        cardName = data.card_holder;
        delete data["card_holder"];

        cardCvv = data.cvv;
        delete data["cvv"];

        cardYear = data.expiry_year;
        delete data["expiry_year"];

        cardMonth = data.expiry_month;
        delete data["expiry_month"];
        delete data["expiry_year_short"];
        delete data["expiry"];
        
        cardType = data.card_type;
        delete data["card_type"];
        
        // everything left over would have been extra_data
        if (Object.keys(data).length > 0) {
          extraData = data;
        }

        // ensure that the UI is updated before continuing
        await tick();

        result = "Card data successfully retrieved.";
        if (cardNumber?.length) {
          isCardRetrieved = true;
        }

      }).catch(async function (r) {
        result = "An error occurred, refresh the page and try again."
      })
    }

    const copyNumberToClipboard = async () => {
      await navigator.clipboard.writeText(cardNumber);
      isNumberCopiedToClipboard = true;
    }

    let isNumberCopiedToClipboard = false;
    let submit_button_width = 300
    let submit_font_size
    $: submit_font_size = Math.round(0.05 * submit_button_width)
</script>

<div id="pcivault-pcd-form-container" class="card-form">
  {#if show_card}
    <div id="pcivault-pcd-form-card-container" style="padding-bottom: 32px">
      <CreditCard
        asset_url={pci_address_prod + "/assets"}
        cardType={cardType}
        cardNumberMask={cardNumberMask}
        isCardFlipped={isCardFlipped}
        cardNumber={cardNumber}
        hideCardNumber={isRetrieval && !cardInputVisible}
        cardName={cardName}
        expiry={expiry}
        cardCvv={cardCvv}
        hideCvv={isRetrieval}
      />
    </div>
  {/if}
  <div id="pcivault-pcd-form-inner-container" class="card-form__inner">
    {#if fieldSettings.card_number.visible}
      <div id="pcivault-pcd-form-number-input" class="card-input">
        {#if cardKeypad}
          <Keypad bind:number={cardNumber} on:close={() => cardKeypad = false}/>
        {/if}
        <label id="pcivault-pcd-form-number-input-label" for="cardNumber" class="card-input__label">
          Card Number
          {#if !validNumber}
            <span id="pcivault-pcd-form-number-input-label-error" class="card-input__error">
              {cardNumber ? "invalid credit card number" : "required"}
            </span>
          {/if}
        </label>

        {#if cardInputVisible}
          <input type="text" id="cardNumber" class="card-input__input" class:card-input__invalid={!validNumber}
                 bind:value={cardNumber}
                 on:focus={() => cardKeypad = force_keypad}
                 on:keypress={(e) => {cardKeypad && e.preventDefault(); return !cardKeypad}}
                 disabled={isRetrieval}
                 autocomplete="cc-number" />
        {:else}
          <input type="password" id="cardNumberHidden" class="card-input__input" class:card-input__invalid={!validNumber}
                 bind:value={cardNumber}
                 on:focus={() => cardKeypad = force_keypad}
                 on:keypress={(e) => {cardKeypad && e.preventDefault(); return !cardKeypad}}
                 disabled={isRetrieval}
                 autocomplete="cc-number" />
        {/if}

        {#if isCardRetrieved}
          <div class="actions">
            <span class="action" on:click={copyNumberToClipboard}>
              {#if isNumberCopiedToClipboard}
                <span title="Copied to Clipboard" class="action-success"><IconClipboardCheck size={16} /></span>
              {:else}
                <span title="Copy to Clipboard"><IconClipboard size={16} /></span>
              {/if}
            </span>
            <span class="action" on:click={() => cardInputVisible = !cardInputVisible} title="Show Number">
              <IconEye size={16} />
            </span>
          </div>
        {/if}
      </div>
    {/if}
    {#if fieldSettings.card_holder.visible}
      <div id="pcivault-pcd-form-name-input" class="card-input">
        <label id="pcivault-pcd-form-name-input-label" for="cardName" class="card-input__label">
          Card Holder
          {#if !validHolder}
            <span id="pcivault-pcd-form-name-input-label-error" class="card-input__error">required</span>
          {/if}
        </label>
        <input type="text" id="cardName" class="card-input__input" class:card-input__invalid={!validHolder}
               bind:value={cardName} autocomplete="cc-name"
               disabled={isRetrieval} />
      </div>
    {/if}
    <div id="pcivault-pcd-form-expiry-cvv-row" class="card-form__row">
      {#if fieldSettings.expiry.visible}
        <div id="pcivault-pcd-form-date-input" class="card-input">
          <label id="pcivault-pcd-form-date-input-label" for="cardMonth" class="card-input__label">
            Expiration Date
            {#if !validMonth || !validYear}
              <span class="card-input__error">required</span>
            {/if}
          </label>
          <div id="pcivault-pcd-form-date-input-group" class="card-form__group">
            <select class="card-input__input select" id="cardMonth" class:card-input__invalid={!validMonth}
                    bind:value={cardMonth}
                    disabled={isRetrieval}>
              <option value="" disabled selected>Month</option>
              {#each Array(12) as _, n}
                <option value={(n+1) < 10 ? '0' + (n+1) : (n+1)} disabled={(n+1) < parseInt(minCardMonth)}>
                  {(n + 1) < 10 ? '0' + (n + 1) : (n + 1)}
                </option>
              {/each}
            </select>
            <select class="card-input__input select" id="cardYear" class:card-input__invalid={!validYear}
                    bind:value={cardYear}
                    disabled={isRetrieval}>
              <option value="" disabled selected>Year</option>
              {#each Array(12) as _, n}
                <option value={(n + parseInt(minCardYear)).toString(10)}>
                  {(n + parseInt(minCardYear)).toString(10)}
                </option>
              {/each}
            </select>
          </div>
        </div>
      {/if}
      {#if fieldSettings.cvv.visible && !isRetrieval}
        <div id="pcivault-pcd-form-cvv-input" class="card-input cvv">
          <label id="pcivault-pcd-form-cvv-input-label" for="cardCvv" class="card-input__label">
            CVV
            {#if !validCVV}
              <span id="pcivault-pcd-form-cvv-input-label-error" class="card-input__error">required</span>
            {/if}
          </label>
          <input type="text" class="card-input__input" id="cardCvv" maxlength="4" class:card-input__invalid={!validCVV}
                 bind:value={cardCvv} on:focus={() => isCardFlipped = true} on:blur={() => isCardFlipped = false}
                 autocomplete="cc-csc" disabled={isRetrieval}>
        </div>
      {/if}
    </div>
    {#if isRetrieval && Object.keys(extraData).length}
    <div class="card-form__row">
      <span class="extra-data__label">
        Additional Data
      </span>
      <div class="extra-data"> 
        <pre>{JSON.stringify(extraData, null, 2)}</pre>
      </div>
    </div>
    {/if}
    
    {#if !isRetrieval}
      <button id="pcivault-pcd-form-button-submit" class="card-form__button" on:click={submit}
              disabled='{!allValid || result}' bind:clientWidth={submit_button_width}
              style="font-size:{submit_font_size}px;">
        SECURE CAPTURE CARD
      </button>
    {/if}
    {#if result}
      <div id="pcivault-pcd-form-submit-result"
          class="card-input__result {result.includes('error') ? 'card-input__error' : 'card-input__success'}">
        {result}
      </div>
    {/if}
  </div>
</div>

<style>
    @font-face {
        font-family: "SFProDisplay";
        src: url("/assets/SFProDisplay-Light.woff2");
        font-weight: 300;
    }

    @font-face {
        font-family: "SFProDisplay";
        src: url("/assets/SFProDisplay-Regular.woff2");
        font-weight: normal;
    }

    @font-face {
        font-family: "SFProDisplay";
        src: url("/assets/SFProDisplay-Medium.woff2");
        font-weight: 500;
    }

    @font-face {
        font-family: "SFProDisplay";
        src: url("/assets/SFProDisplay-Bold.woff2");
        font-weight: bold;
    }

    * {
        box-sizing: border-box;
    }

    *:focus {
        outline: none;
    }

    .card-form {
        max-width: 512px;
        margin: auto;
        width: 100%;

        background: white;
        box-shadow: 0 30px 60px 0 rgba(90, 116, 148, 0.4);
        border-radius: 10px;
        padding: 16px 0 16px 0;

        font-family: "SFProDisplay", sans-serif;
    }

    .card-form__inner {
        padding: 16px;
    }

    .card-form__row {
        width: 100%;
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        align-content: stretch;
        flex-wrap: wrap;
        gap: 0 0.5rem;
    }

    .card-form__group {
        width: 100%;
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 0 0.5rem;
    }

    .card-form__row .card-input {
        flex: 1 1 100px;
    }

    .card-form__row .extra-data {
      padding: 10px;
      color: #1a3b5d;
      background-color: #eee;
      border-radius: 5px;
      width: 100%;
    }
    .extra-data__label {
        font-size: 14px;
        margin-bottom: 5px;
        font-weight: 500;
        color: #1a3b5d;
        width: 100%;
        display: block;
    }

    .card-form__button {
        width: 100%;
        height: 55px;
        background: #009844;
        border: none;
        border-radius: 5px;
        font-size: 22px;
        font-weight: 500;

        box-shadow: 3px 10px 20px 0 rgba(35, 100, 210, 0.3);
        color: #fff;
        margin-top: 10px;
        cursor: pointer;
    }

    .card-form__button:disabled {
        background: #A7A5A5;
        cursor: default;
    }

    .card-input {
        margin-bottom: 16px;
        position: relative;
    }

    .card-input.cvv {
        min-width: 5rem;
        flex-shrink: 1;
    }

    .card-input__label {
        font-size: 14px;
        margin-bottom: 5px;
        font-weight: 500;
        color: #1a3b5d;
        width: 100%;
        display: block;
    }

    .card-input__input {
        width: 100%;
        min-width: 7.5rem;
        height: 50px;
        border-radius: 5px;
        box-shadow: none;
        border: 1px solid #ced6e0;
        transition: all 0.3s ease-in-out;
        font-size: 18px;
        padding: 5px 15px;
        background: none;
        color: #1a3b5d;
        font-family: "Source Sans Pro", sans-serif;
    }

    .card-input__input:hover, .card-input__input:focus {
        border-color: #3d9cff;
    }

    .card-input__input:focus {
        box-shadow: 0 10px 20px -13px rgba(32, 56, 117, 0.35);
    }

    .card-input__input.select {
        -webkit-appearance: none;
        background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAeCAYAAABuUU38AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAUxJREFUeNrM1sEJwkAQBdCsngXPHsQO9O5FS7AAMVYgdqAd2IGCDWgFnryLFQiCZ8EGnJUNimiyM/tnk4HNEAg/8y6ZmMRVqz9eUJvRaSbvutCZ347bXVJy/ZnvTmdJ862Me+hAbZCTs6GHpyUi1tTSvPnqTpoWZPUa7W7ncT3vK4h4zVejy8QzM3WhVUO8ykI6jOxoGA4ig3BLHcNFSCGqGAkig2yqgpEiMsjSfY9LxYQg7L6r0X6wS29YJiYQYecemY+wHrXD1+bklGhpAhBDeu/JfIVGxaAQ9sb8CI+CQSJ+QmJg0Ii/EE2MBiIXooHRQhRCkBhNhBcEhLkwf05ZCG8ICCOpk0MULmvDSY2M8UawIRExLIQIEgHDRoghihgRIgiigBEjgiFATBACAgFgghEwSAAGgoBCBBgYAg5hYKAIFYgHBo6w9RRgAFfy160QuV8NAAAAAElFTkSuQmCC");
        background-size: 12px;
        background-position: 90% center;
        background-repeat: no-repeat;
        padding-right: 30px;
    }

    .card-input__invalid {
        border-color: red;
    }

    .card-input__error {
        color: red;
        font-style: italic;
    }

    .card-input__success {
        color: #12B331;
    }

    .card-input__result {
        margin-top: 16px;
        text-align: center;
        font-style: italic;
    }

    .card-input .actions {
      color: #1a3b5d;
      position: absolute;
      right: 10px;
      top: 40px;
    }

    .card-input .actions .action-success {
      color: #12B331;
    }

    .card-input .actions .action {
      cursor: pointer;
      display: inline-block;
      vertical-align: middle;
    }

</style>

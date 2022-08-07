// import Flatpickr
import Flatpickr from "stimulus-flatpickr";
import { ar } from "flatpickr/dist/l10n/ar";
import { cat } from "flatpickr/dist/l10n/cat";
import { cy } from "flatpickr/dist/l10n/cy";
import { de } from "flatpickr/dist/l10n/de";
import { fr } from "flatpickr/dist/l10n/fr";
import { it } from "flatpickr/dist/l10n/it";
import { nl } from "flatpickr/dist/l10n/nl";
import { pl } from "flatpickr/dist/l10n/pl";
import { pt } from "flatpickr/dist/l10n/pt";
import { ru } from "flatpickr/dist/l10n/ru";
import { sv } from "flatpickr/dist/l10n/sv";
import { tr } from "flatpickr/dist/l10n/tr";
import { en } from "flatpickr/dist/l10n/default.js";
import ShortcutButtonsPlugin from "shortcut-buttons-flatpickr";
import labelPlugin from "flatpickr/dist/plugins/labelPlugin/labelPlugin";

export default class extends Flatpickr {
  static values = { enableTime: Boolean, mode: String };
  static targets = ["start", "end"];
  locales = {
    ar: ar,
    cat: cat,
    cy: cy,
    de: de,
    fr: fr,
    it: it,
    nl: nl,
    pl: pl,
    pt: pt,
    ru: ru,
    sv: sv,
    tr: tr,
    en: en,
  };

  initialize() {
    const datetimepicker = this.enableTimeValue == true;
    const mode = this.modeValue == "range" ? "range" : "single";
    // sets your language (you can also set some global setting for all time pickers)
    this.config = {
      altInput: true,
      altFormat: datetimepicker
        ? Spree.translations.flatpickr_datetime_format
        : Spree.translations.flatpickr_date_format,
      dateFormat: datetimepicker ? "Y-m-d H:i" : "Y-m-d",
      enableTime: datetimepicker,
      time_24hr: datetimepicker,
      locale: I18n.base_locale,
      plugins: this.plugins(mode, datetimepicker),
      mode,
    };
  }

  clear(e) {
    this.fp.setDate(null);
  }

  change(selectedDates, dateStr, instance) {
    if (this.hasStartTarget && this.hasEndTarget) {
      this.startTarget.value = selectedDates[0]
        ? this.fp.formatDate(selectedDates[0], this.config.dateFormat)
        : "";
      this.endTarget.value = selectedDates[1]
        ? this.fp.formatDate(selectedDates[1], this.config.dateFormat)
        : "";
      // Also, send event to be sure that ng-model is well updated
      this.startTarget.dispatchEvent(new Event("change"));
      this.endTarget.dispatchEvent(new Event("change"));
    }
  }

  // private

  plugins = (mode, datetimepicker) => {
    const buttons = [{ label: Spree.translations.close }];
    if (mode == "single") {
      buttons.unshift({
        label: datetimepicker
          ? Spree.translations.now
          : Spree.translations.today,
      });
    }
    return [
      ShortcutButtonsPlugin({
        button: buttons,
        label: mode != "range" && "or",
        onClick: this.onClickButtons,
      }),
      labelPlugin({}),
    ];
  };

  onClickButtons = (index, fp) => {
    // Memorize index used for the 'Close' and 'Today|Now' buttons
    // it has index of 1 in case of single mode (ie. can set Today or Now date)
    // it has index of 0 in case of range mode (no Today or Now button)
    const closeButtonIndex = this.modeValue == "range" ? 0 : 1;
    const todayButtonIndex = this.modeValue == "range" ? null : 0;
    switch (index) {
      case todayButtonIndex:
        fp.setDate(new Date(), true);
        break;
      case closeButtonIndex:
        fp.close();
        break;
    }
  };
}

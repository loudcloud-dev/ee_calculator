import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="leave-request"
export default class extends Controller {
  static targets = [
    "startDate",
    "endDate",
    "dayCount",
    "remainingSL",
    "remainingVL",
  ];

  connect() {
    this.selectedType = document.querySelector(
      "input[type='radio']:checked",
    )?.value;
  }

  handleStartDateChange() {
    const startDate = this.startDateTarget.value;
    const endDate = this.endDateTarget.value;

    if (startDate) {
      this.endDateTarget.min = startDate;
    } else {
      this.endDateTarget.removeAttribute("min");
    }

    if (startDate && endDate)
      this.dayCountTarget.value = this.getWeekdayCount(
        new Date(startDate),
        new Date(endDate),
      );
  }

  handleEndDateChange() {
    const startDate = this.startDateTarget.value;
    const endDate = this.endDateTarget.value;

    if (endDate) {
      this.startDateTarget.max = endDate;
    } else {
      this.startDateTarget.removeAttribute("max");
    }

    if (startDate && endDate)
      this.dayCountTarget.value = this.getWeekdayCount(
        new Date(startDate),
        new Date(endDate),
      );
  }

  handleDayCountChange() {
    const startDate = this.startDateTarget.value;
    let dayCount = this.dayCountTarget.value;

    if (dayCount < 1) this.dayCountTarget.value = 1;

    dayCount = this.dayCountTarget.value;

    this.endDateTarget.value = this.calculateEndDate(
      new Date(startDate),
      dayCount,
    )
      .toISOString()
      .slice(0, 10);
  }

  handleTypeSelect(event) {
    this.selectedType = event.target.value;
  }

  validateForm(event) {
    const selectedType = this.selectedType;
    const dayCount = this.dayCountTarget.value;
    let remainingLeaves = 15;

    if (selectedType == "sick") {
      remainingLeaves = parseInt(this.remainingSLTarget.innerHTML);
    } else if (selectedType == "vacation") {
      remainingLeaves = parseInt(this.remainingVLTarget.innerHTML);
    }

    if (dayCount > remainingLeaves && event.submitter.id != "modalConfirm") {
      event.preventDefault();

      const trigger = new CustomEvent("modal-open");
      window.dispatchEvent(trigger);
    }
  }

  getWeekdayCount(startDate, endDate) {
    // https://stackoverflow.com/a/29945360
    var elapsed, daysBeforeFirstSat, daysAfterLastSun;
    var ifThen = function (a, b, c) {
      return a == b ? c : a;
    };

    elapsed = endDate - startDate;
    elapsed /= 86400000;

    daysBeforeFirstSat = (7 - startDate.getDay()) % 7;
    daysAfterLastSun = endDate.getDay();

    elapsed -= daysBeforeFirstSat + daysAfterLastSun;
    elapsed = (elapsed / 7) * 5;
    elapsed +=
      ifThen(daysBeforeFirstSat - 1, -1, 0) + ifThen(daysAfterLastSun, 6, 5);

    return Math.ceil(elapsed);
  }

  calculateEndDate(startDate, dayCount) {
    let endDate = startDate;
    let increment = 0;

    while (increment < dayCount) {
      const dayOfWeek = endDate.getDay();
      if (dayOfWeek !== 0 && dayOfWeek !== 6) {
        increment++;
        if (increment == dayCount) break;
      }

      endDate.setDate(endDate.getDate() + 1);
    }

    return endDate;
  }
}

import { test, expect, Page } from "@playwright/test";

let p: Page;

test("Consent", async ({ page }) => {
  p = page;
  await given_the_app_is_setup();

  await given_i_am_doing_triage();
  await when_i_select_a_child_with_no_consent_response();
  await and_i_click_get_consent();
  await then_the_consent_form_is_empty();

  await given_i_call_the_parent_and_they_refuse_consent();
  await when_i_record_the_consent_refused();
  await and_i_record_the_reason_for_refusal();
  // TODO: This is a bug in the app, their status should be do not vaccinate.
  await then_i_see_that_the_child_needs_their_refusal_checked();
});

async function given_the_app_is_setup() {
  await p.goto("/reset");
}

async function given_i_am_doing_triage() {
  await p.goto("/sessions/1/triage");
}

async function when_i_select_a_child_with_no_consent_response() {
  await p.getByRole("tab", { name: "Get consent" }).click();
  await p.getByRole("link", { name: "Alexandra Sipes" }).click();
}

async function when_i_click_get_consent() {
  await p.getByRole("button", { name: "Get consent" }).click();
}
const and_i_click_get_consent = when_i_click_get_consent;

async function then_the_consent_form_is_empty() {
  await expect(p.locator('[name="consent[parent_name]"]')).toBeEmpty();
  await expect(p.locator('[name="consent[parent_phone]"]')).toBeEmpty();
  await expect(p.locator("text=Mum")).not.toBeChecked();
}

async function given_i_call_the_parent_and_they_refuse_consent() {}

async function when_i_record_the_consent_refused() {
  // Who
  await p.fill('[name="consent[parent_name]"]', "Jane Doe");
  await p.fill('[name="consent[parent_phone]"]', "07700900000");
  await p.click("text=Mum");
  await p.getByRole("button", { name: "Continue" }).click();

  // Do they agree
  await p.getByRole("radio", { name: "No, they do not agree" }).click();
  await p.getByRole("button", { name: "Continue" }).click();
}

async function and_i_record_the_reason_for_refusal() {
  // Why do they not agree
  await p.getByRole("radio", { name: "Personal choice" }).click();

  await p.getByRole("button", { name: "Continue" }).click();

  await p.getByRole("button", { name: "Confirm" }).click();
}

async function then_i_see_that_the_child_needs_their_refusal_checked() {
  await expect(p.locator(".nhsuk-notification-banner__content")).toContainText(
    "Consent saved for Alexandra Sipes",
  );
  await p.getByRole("tab", { name: "No triage needed" }).click();
  const row = p.locator(`tr`, { hasText: "Alexandra Sipes" });
  await expect(row).toBeVisible();
  await expect(row.getByTestId("child-action")).toContainText("Check refusal");
}
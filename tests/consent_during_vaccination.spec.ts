import { test, expect, Page } from "@playwright/test";

let p: Page;

test("Records consent and then allows vaccination", async ({ page }) => {
  p = page;
  await given_the_app_is_setup();

  await when_i_go_to_the_vaccinations_page();
  await when_i_click_on_a_patient_that_needs_consent();
  await then_i_see_the_vaccination_page();

  await when_i_click_yes_i_am_contacting_a_parent();
  await and_i_click_continue();
  await then_i_see_the_new_consent_form();

  await when_i_go_through_the_consent_and_triage_forms();
  await then_i_see_the_vaccination_form();
});

async function given_the_app_is_setup() {
  await p.goto("/reset");
}

async function when_i_go_to_the_vaccinations_page() {
  await p.goto("/sessions/1/vaccinations");
}

async function when_i_click_on_a_patient_that_needs_consent() {
  await p.click("text=Alexandra Sipes");
}

async function then_i_see_the_vaccination_page() {
  expect(await p.innerText("h1")).toContain("Alexandra Sipes");
}

async function when_i_click_yes_i_am_contacting_a_parent() {
  await p.click("text=Yes, I am contacting a parent or guardian");
}

async function and_i_click_continue() {
  await p.click("text=Continue");
}

async function then_i_see_the_new_consent_form() {
  expect(await p.innerText("h1")).toContain(
    "Who are you trying to get consent from?",
  );
}

async function when_i_go_through_the_consent_and_triage_forms() {
  // Who
  await p.fill('[name="consent_response[parent_name]"]', "Jane Doe");
  await p.fill('[name="consent_response[parent_phone]"]', "07412345678");
  await p.click("text=Mum");
  await p.click("text=Continue");

  // Do they agree
  await p.click("text=Yes, they agree");
  await p.click("text=Continue");

  // Health questions
  const radio = (n: number) =>
    `input[name="consent_response[question_${n}][response]"][value="no"]`;

  await p.click(radio(0));
  await p.click(radio(1));
  await p.click(radio(2));
  await p.click(radio(3));

  // Triage
  await p.click("text=Ready to vaccinate");
  await p.click("text=Continue");

  // Check answers
  await p.getByRole("button", { name: "Confirm" }).click();
}

async function then_i_see_the_vaccination_form() {
  expect(await p.innerText("h1")).toContain("Did they get the vaccine?");
}

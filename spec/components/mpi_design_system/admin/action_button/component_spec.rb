# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::ActionButton::Component, type: :component do
  it "renders a primary filled button by default" do
    render_inline(described_class.new(label: "Save"))

    expect(page).to have_css("button.btn.btn-primary", text: "Save")
  end

  it "renders an outline variant" do
    render_inline(described_class.new(label: "Filter", variant: :outline))

    expect(page).to have_css("button.btn.btn-outline-primary", text: "Filter")
  end

  it "renders with a specific color" do
    render_inline(described_class.new(label: "Delete", color: :danger))

    expect(page).to have_css("button.btn.btn-danger", text: "Delete")
  end

  it "renders at small size" do
    render_inline(described_class.new(label: "Edit", size: :sm))

    expect(page).to have_css("button.btn.btn-sm")
  end

  it "renders with an icon including bi base class" do
    render_inline(described_class.new(label: "Add Contact", icon: "bi-plus-lg"))

    expect(page).to have_css("i.bi.bi-plus-lg.me-1")
    expect(page).to have_text("Add Contact")
  end

  it "renders icon-only with aria-label" do
    render_inline(described_class.new(label: "Edit", icon: "bi-pencil", icon_only: true))

    expect(page).to have_css("button[aria-label='Edit']")
    expect(page).to have_css("i.bi.bi-pencil")
    expect(page).not_to have_text("Edit")
  end

  it "renders as a link when href is provided" do
    render_inline(described_class.new(label: "View", href: "/contacts/1"))

    expect(page).to have_css("a.btn.btn-primary[href='/contacts/1']", text: "View")
  end

  it "renders a disabled button with disabled attribute" do
    render_inline(described_class.new(label: "Submit", disabled: true))

    expect(page).to have_css("button[disabled]")
    expect(page).to have_css("button[aria-disabled='true']")
  end

  it "renders a disabled link with disabled class and tabindex" do
    render_inline(described_class.new(label: "View", href: "/contacts/1", disabled: true))

    expect(page).to have_css("a.btn.disabled[aria-disabled='true'][tabindex='-1']")
    expect(page).not_to have_css("a[disabled]")
  end

  it "includes turbo method data attribute" do
    render_inline(described_class.new(label: "Delete", color: :danger, href: "/contacts/1", method: :delete))

    expect(page).to have_css("a[data-turbo-method='delete']")
  end

  context "with classes_append" do
    it "appends a single class to a button" do
      render_inline(described_class.new(label: "Save", classes_append: "float-end"))

      expect(page).to have_css("button.btn.btn-primary.float-end", text: "Save")
    end

    it "splits a space-separated string into individual classes" do
      render_inline(described_class.new(label: "Save", classes_append: "float-end me-2"))

      expect(page).to have_css("button.btn.btn-primary.float-end.me-2")
    end

    it "accepts an array of classes" do
      render_inline(described_class.new(label: "Save", classes_append: [ "float-end", "me-2" ]))

      expect(page).to have_css("button.btn.btn-primary.float-end.me-2")
    end

    it "appends after the derived classes" do
      render_inline(described_class.new(label: "Save", classes_append: "float-end"))

      expect(page.find("button")[:class]).to eq("btn btn-primary float-end")
    end

    it "applies to the anchor render" do
      render_inline(described_class.new(label: "View", href: "/contacts/1", classes_append: "float-end"))

      expect(page).to have_css("a.btn.btn-primary.float-end[href='/contacts/1']", text: "View")
    end

    it "combines with a non-default size" do
      render_inline(described_class.new(label: "Edit", size: :sm, classes_append: "me-2"))

      expect(page).to have_css("button.btn.btn-primary.btn-sm.me-2")
    end

    it "combines with a disabled link without losing the disabled class" do
      render_inline(described_class.new(label: "View", href: "/contacts/1", disabled: true, classes_append: "float-end"))

      expect(page).to have_css("a.btn.disabled.float-end[aria-disabled='true'][tabindex='-1']")
    end

    it "still drops the turbo method on a disabled link" do
      render_inline(described_class.new(label: "Delete", href: "/contacts/1", method: :delete, disabled: true))

      expect(page).not_to have_css("a[data-turbo-method]")
    end

    it "renders only the derived classes when omitted" do
      render_inline(described_class.new(label: "Save"))

      expect(page.find("button")[:class]).to eq("btn btn-primary")
    end

    it "rejects blank and nil entries" do
      render_inline(described_class.new(label: "Save", classes_append: [ "ms-2", "", nil, "  " ]))

      expect(page.find("button")[:class]).to eq("btn btn-primary ms-2")
    end
  end

  context "with an href performing a non-GET action" do
    it "renders role='button'" do
      render_inline(described_class.new(label: "Delete", href: "/contacts/1", method: :delete))

      expect(page).to have_css("a.btn[role='button'][data-turbo-method='delete']")
    end

    it "keeps role='button' when disabled" do
      render_inline(described_class.new(label: "Delete", href: "/contacts/1", method: :delete, disabled: true))

      expect(page).to have_css("a.btn.disabled[role='button'][aria-disabled='true']")
    end
  end

  context "with an href used for navigation" do
    it "renders no role when the method is :get" do
      render_inline(described_class.new(label: "View", href: "/contacts/1", method: :get))

      expect(page).not_to have_css("a[role]")
    end

    it "renders no role when no method is given" do
      render_inline(described_class.new(label: "View", href: "/contacts/1"))

      expect(page).not_to have_css("a[role]")
    end

    it "renders the explicit role override when given" do
      render_inline(described_class.new(label: "View", href: "/contacts/1", method: :get, role: "button"))

      expect(page).to have_css("a[role='button']")
    end
  end

  context "without an href" do
    it "renders no role on a plain button" do
      render_inline(described_class.new(label: "Save"))

      expect(page).not_to have_css("button[role]")
    end
  end

  context "with the info color" do
    it "renders a filled info button" do
      render_inline(described_class.new(label: "Details", color: :info))

      expect(page).to have_css("button.btn.btn-info", text: "Details")
    end

    it "renders an outline info button" do
      render_inline(described_class.new(label: "Details", color: :info, variant: :outline))

      expect(page).to have_css("button.btn.btn-outline-info", text: "Details")
    end
  end

  context "with an unknown color" do
    it "falls back to the primary color" do
      render_inline(described_class.new(label: "Save", color: :nope))

      expect(page).to have_css("button.btn.btn-primary")
    end
  end
end

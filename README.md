lego
====

Hapi html templating

## Define

Define custom snippets of HTML inside templates to include with insert command

**Examples:**

This defines a context-less block of code to be inserted anywhere

  <!-- lego::define customTemplate -->
    <div class="someBlockClass"></div>
  <!-- lego::enddefine -->

This defines a block of code with a context, who's context will only be resolved when actually inserted

  <!-- lego::define customTemplate -->
    <div class="<!-- lego::insert $this -->"></div>
  <!-- lego::enddefine -->
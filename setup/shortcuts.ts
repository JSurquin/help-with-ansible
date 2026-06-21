import type { NavOperations, ShortcutOptions } from "@slidev/types";
import { defineShortcutsSetup } from "@slidev/types";

export default defineShortcutsSetup(
  (nav: NavOperations, base: ShortcutOptions[]) => {
    return [
      ...base, // keep the existing shortcuts
      {
        key: "enter",
        fn: () => nav.next(),
        autoRepeat: true,
      },
      {
        key: "a",
        fn: () => nav.go("sommaire"),
        autoRepeat: true,
      },
      {
        key: "backspace",
        fn: () => nav.prev(),
        autoRepeat: true,
      },
      {
        key: "n",
        fn: () => nav.toggleDrawing(),
        autoRepeat: true,
      },
      {
        key: "n",
        fn: () => nav.toggleDrawing(),
        autoRepeat: true,
      },
      {
        key: "h",
        fn: () => nav.goFirst(), // Go to first slide
        autoRepeat: false,
      },
      {
        key: "p",
        fn: () => nav.goLast(), // Go to last slide
        autoRepeat: false,
      },
      {
        key: "s",
        fn: () => nav.downloadPDF(), // Download PDF
        autoRepeat: false,
      },
      {
        key: "go",
        fn: () => nav.showGotoDialog(), // Show navigation dialog
        autoRepeat: false,
      },
    ];
  },
);

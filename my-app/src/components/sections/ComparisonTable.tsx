"use client";

import React from "react";
import { motion } from "framer-motion";
import { Check, X, Minus } from "lucide-react";
import { COMPARISON_TABLE } from "@/utils/constants";
import { cn } from "@/utils/cn";

function CellValue({ value }: { value: boolean | string }) {
  if (typeof value === "string") {
    return <span className="text-sm font-body text-ink-green/70">{value}</span>;
  }
  if (value) {
    return (
      <div className="w-6 h-6 rounded-full bg-chalk-teal/10 flex items-center justify-center mx-auto">
        <Check className="w-3.5 h-3.5 text-chalk-teal" />
      </div>
    );
  }
  return (
    <div className="flex justify-center">
      <Minus className="w-4 h-4 text-ink-green/20" />
    </div>
  );
}

export default function ComparisonTable() {
  return (
    <section className="section-padding bg-paper">
      <div className="container-main">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
        >
          <div className="overflow-x-auto pb-4 -mx-4 px-4 sm:mx-0 sm:px-0">
            <div className="min-w-[700px]">
              {/* Table Header */}
              <div className="grid grid-cols-4 gap-4 mb-4">
                <div className="text-lg font-display font-bold text-ink-green">
                  Compare Plans
                </div>
                <div className="text-center">
                  <p className="text-base font-display font-semibold text-ink-green">
                    Basic
                  </p>
                </div>
                <div className="text-center">
                  <div className="inline-block">
                    <span className="block text-[10px] bg-brass-gold text-white px-2 py-0.5 rounded-full font-body font-semibold uppercase tracking-wider mb-1">
                      Most Popular
                    </span>
                    <p className="text-base font-display font-semibold text-ink-green">
                      Pro
                    </p>
                  </div>
                </div>
                <div className="text-center">
                  <p className="text-base font-display font-semibold text-ink-green">
                    Enterprise
                  </p>
                </div>
              </div>

          {/* Table Rows */}
          <div className="bg-card-surface rounded-2xl shadow-card overflow-hidden">
            {COMPARISON_TABLE.map((row, i) => (
              <div
                key={row.feature}
                className={cn(
                  "grid grid-cols-4 gap-4 px-6 py-4 items-center",
                  i !== COMPARISON_TABLE.length - 1 && "border-b border-paper"
                )}
              >
                <div className="flex items-center gap-2">
                  <row.icon className="w-4 h-4 text-ink-green/40 flex-shrink-0" />
                  <span className="text-sm font-body text-ink-green">
                    {row.feature}
                  </span>
                </div>
                <div className="text-center">
                  <CellValue value={row.basic} />
                </div>
                <div className="text-center">
                  <CellValue value={row.pro} />
                </div>
                <div className="text-center">
                  <CellValue value={row.enterprise} />
                </div>
              </div>
            ))}
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}

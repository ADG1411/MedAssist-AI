import React from 'react';

interface TimeInputProps {
  label: string;
  value: string;
  onChange: (val: string) => void;
  disabled?: boolean;
}

export const TimeInput: React.FC<TimeInputProps> = ({ label, value, onChange, disabled }) => {
  return (
    <div className="flex flex-col">
      <label className="text-xs font-semibold text-gray-600 mb-1.5 uppercase tracking-wide">{label}</label>
      <input
        type="time"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        disabled={disabled}
        className="border border-gray-300 rounded-lg px-3 py-2.5 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 disabled:bg-gray-100 disabled:text-gray-400 transition-shadow outline-none"
      />
    </div>
  );
};
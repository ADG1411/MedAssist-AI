import React, { Component, ErrorInfo, ReactNode } from 'react';
import { AlertCircle, RefreshCcw } from 'lucide-react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false,
    error: null
  };

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Uncaught error:', error, errorInfo);
  }

  public render() {
    if (this.state.hasError) {
      if (this.props.fallback) return this.props.fallback;
      
      return (
        <div className="flex flex-col items-center justify-center p-8 bg-red-50 rounded-2xl border border-red-200 min-h-[300px]">
          <AlertCircle className="w-12 h-12 text-red-500 mb-4" />
          <h2 className="text-lg font-black text-red-800 mb-2">Something went wrong</h2>
          <p className="text-[13px] text-red-600 font-medium text-center max-w-sm mb-6">
            The scanner or visual component crashed unexpectedly. Click reload to refresh the view.
          </p>
          <button
            onClick={() => this.setState({ hasError: false })}
            className="flex items-center gap-2 bg-red-500 hover:bg-red-600 text-white px-5 py-2.5 rounded-xl text-[13px] font-bold transition-all"
          >
            <RefreshCcw className="w-4 h-4" />
            Reload Module
          </button>
          {this.state.error && (
            <p className="text-[10px] text-red-400 font-mono mt-4 break-all max-w-sm border-t border-red-200/50 pt-2">
              {this.state.error.message}
            </p>
          )}
        </div>
      );
    }

    return this.props.children;
  }
}
